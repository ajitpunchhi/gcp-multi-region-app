# Cloud Storage buckets
resource "google_storage_bucket" "default" {
  for_each = var.storage_configs

  name          = "${var.project_id}-${var.environment}-${each.key}"
  location      = each.value.location
  project       = var.project_id
  storage_class = each.value.storage_class
  force_destroy = var.environment != "prod"

  # Versioning
  versioning {
    enabled = each.value.versioning
  }

  # Lifecycle rules
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 730
    }
    action {
      type = "Delete"
    }
  }

  # Bucket-level access control
  uniform_bucket_level_access = true

  # Encryption
  encryption {
    default_kms_key_name = null  # Use Google-managed keys
  }

  # CORS rules (if needed for web access)
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  # Logging (optional)
  logging {
    log_bucket        = google_storage_bucket.logging_bucket.name
    log_object_prefix = "bucket-logs/${each.key}/"
  }

  labels = merge(var.labels, {
    bucket-type = each.key
  })
}

# Logging bucket for other buckets
resource "google_storage_bucket" "logging_bucket" {
  name          = "${var.project_id}-${var.environment}-logs"
  location      = var.storage_configs["primary"].location
  project       = var.project_id
  storage_class = "STANDARD"
  force_destroy = var.environment != "prod"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = merge(var.labels, {
    bucket-type = "logging"
  })
}

# IAM bindings for application access
resource "google_storage_bucket_iam_member" "app_access" {
  for_each = var.storage_configs

  bucket = google_storage_bucket.default[each.key].name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.storage_user.email}"
}

# Service account for application access to storage
resource "google_service_account" "storage_user" {
  account_id   = "${var.environment}-storage-user"
  display_name = "Storage User for ${var.environment}"
  project      = var.project_id
}

# Key for the service account
resource "google_service_account_key" "storage_user_key" {
  service_account_id = google_service_account.storage_user.name
}

# Store the service account key in Secret Manager
resource "google_secret_manager_secret" "storage_user_key" {
  secret_id = "${var.environment}-storage-sa-key"
  project   = var.project_id

  replication {
   # automatic = true
  }

  labels = var.labels
}

resource "google_secret_manager_secret_version" "storage_user_key" {
  secret     = google_secret_manager_secret.storage_user_key.id
  secret_data = base64decode(google_service_account_key.storage_user_key.private_key)
}

# Cloud Storage notifications (optional)
resource "google_pubsub_topic" "bucket_notifications" {
  for_each = var.storage_configs

  name    = "${var.environment}-bucket-${each.key}-notifications"
  project = var.project_id

  labels = var.labels
}

resource "google_pubsub_topic_iam_member" "notification_publisher" {
  for_each = var.storage_configs

  topic  = google_pubsub_topic.bucket_notifications[each.key].name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${var.notifications_publisher_sa}"
}

resource "google_storage_notification" "default" {
  for_each = var.storage_configs

  bucket         = google_storage_bucket.default[each.key].name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.bucket_notifications[each.key].id
  event_types    = ["OBJECT_FINALIZE", "OBJECT_DELETE"]
  
  depends_on = [google_pubsub_topic_iam_member.notification_publisher]
}