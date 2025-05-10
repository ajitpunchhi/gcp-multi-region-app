# Random password for database
resource "random_password" "database" {
  length  = 16
  special = true
}

# Store the password in Secret Manager
resource "google_secret_manager_secret" "database_password" {
  secret_id = "${var.environment}-database-password"
  project   = var.project_id

  replication {
    #automatic = true
  }

  labels = var.labels
}

resource "google_secret_manager_secret_version" "database_password" {
  secret     = google_secret_manager_secret.database_password.id
  secret_data = random_password.database.result
}

# Private VPC connection for Cloud SQL
resource "google_compute_global_address" "private_vpc_connection" {
  name          = "${var.environment}-sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_vpc_connection.name]
}

# Primary Cloud SQL instance
resource "google_sql_database_instance" "primary" {
  name             = "${var.environment}-sql-primary"
  database_version = var.sql_configs["primary"].database_version
  region           = var.regions[0]
  project          = var.project_id

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = var.sql_configs["primary"].tier
    availability_type = var.sql_configs["primary"].ha_enabled ? "REGIONAL" : "ZONAL"
    disk_size         = var.sql_configs["primary"].disk_size
    disk_type         = "SSD"
    disk_autoresize   = true

    backup_configuration {
      enabled                        = var.sql_configs["primary"].backup_enabled
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      binary_log_enabled             = true
      location                       = var.regions[0]
      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
      transaction_log_retention_days = 7
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }

    database_flags {
      name  = "max_connections"
      value = "100"
    }

    database_flags {
      name  = "shared_buffers"
      value = "1024"
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
  }

  deletion_protection = var.environment == "prod" ? true : false

  lifecycle {
    ignore_changes = [
      settings[0].disk_size
    ]
  }
}

# Read replica in different region
resource "google_sql_database_instance" "replica" {
  count = length(var.regions) > 1 ? 1 : 0

  name                 = "${var.environment}-sql-replica"
  database_version     = var.sql_configs["replica"].database_version
  region               = var.regions[1]
  master_instance_name = google_sql_database_instance.primary.name
  project              = var.project_id

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = var.sql_configs["replica"].tier
    availability_type = "ZONAL"
    disk_size         = var.sql_configs["replica"].disk_size
    disk_type         = "SSD"
    disk_autoresize   = true

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
      #require_ssl     = true
    }

    database_flags {
      name  = "max_connections"
      value = "100"
    }

    database_flags {
      name  = "shared_buffers"
      value = "1024"
    }
  }

  deletion_protection = var.environment == "prod" ? true : false
}

# Database and user
resource "google_sql_database" "default" {
  name     = "${var.environment}_app"
  instance = google_sql_database_instance.primary.name
  project  = var.project_id
}

resource "google_sql_user" "default" {
  name     = "${var.environment}_user"
  instance = google_sql_database_instance.primary.name
  password = random_password.database.result
  project  = var.project_id
}

# SSL certificates
resource "google_sql_ssl_cert" "client_cert" {
  common_name = "${var.environment}-client-cert"
  instance    = google_sql_database_instance.primary.name
  project     = var.project_id
}

# Store SSL certificate in Secret Manager
resource "google_secret_manager_secret" "ssl_cert" {
  secret_id = "${var.environment}-sql-ssl-cert"
  project   = var.project_id

  replication {
   # automatic = true
  }

  labels = var.labels
}

resource "google_secret_manager_secret_version" "ssl_cert" {
  secret     = google_secret_manager_secret.ssl_cert.id
  secret_data = google_sql_ssl_cert.client_cert.cert
}

resource "google_secret_manager_secret" "ssl_key" {
  secret_id = "${var.environment}-sql-ssl-key"
  project   = var.project_id

  replication {
   # automatic = true
  }

  labels = var.labels
}

resource "google_secret_manager_secret_version" "ssl_key" {
  secret      = google_secret_manager_secret.ssl_key.id
  secret_data = google_sql_ssl_cert.client_cert.private_key
}