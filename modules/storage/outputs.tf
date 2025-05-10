output "bucket_names" {
  description = "Names of created buckets"
  value = {
    for k, v in google_storage_bucket.default : k => v.name
  }
}

output "bucket_urls" {
  description = "URLs of created buckets"
  value = {
    for k, v in google_storage_bucket.default : k => v.url
  }
}

output "bucket_self_links" {
  description = "Self links of created buckets"
  value = {
    for k, v in google_storage_bucket.default : k => v.self_link
  }
}

output "logging_bucket_name" {
  description = "Name of the logging bucket"
  value       = google_storage_bucket.logging_bucket.name
}

output "storage_service_account" {
  description = "Service account email for storage access"
  value       = google_service_account.storage_user.email
}

output "storage_sa_key_secret_id" {
  description = "Secret Manager secret ID for storage service account key"
  value       = google_secret_manager_secret.storage_user_key.secret_id
}

output "notification_topics" {
  description = "Pub/Sub topics for bucket notifications"
  value = {
    for k, v in google_pubsub_topic.bucket_notifications : k => v.name
  }
}