output "sql_instance_names" {
  description = "Cloud SQL instance names"
  value = {
    primary = google_sql_database_instance.primary.name
    replica = length(google_sql_database_instance.replica) > 0 ? google_sql_database_instance.replica[0].name : null
  }
}

output "sql_connection_names" {
  description = "Cloud SQL connection names"
  value = {
    primary = google_sql_database_instance.primary.connection_name
    replica = length(google_sql_database_instance.replica) > 0 ? google_sql_database_instance.replica[0].connection_name : null
  }
}

output "sql_private_ip_addresses" {
  description = "Private IP addresses for Cloud SQL instances"
  value = {
    primary = google_sql_database_instance.primary.private_ip_address
    replica = length(google_sql_database_instance.replica) > 0 ? google_sql_database_instance.replica[0].private_ip_address : null
  }
}

output "database_name" {
  description = "Database name"
  value       = google_sql_database.default.name
}

output "database_user" {
  description = "Database user name"
  value       = google_sql_user.default.name
}

output "password_secret_id" {
  description = "Secret Manager secret ID for database password"
  value       = google_secret_manager_secret.database_password.secret_id
}

output "ssl_cert_secret_id" {
  description = "Secret Manager secret ID for SSL certificate"
  value       = google_secret_manager_secret.ssl_cert.secret_id
}

output "ssl_key_secret_id" {
  description = "Secret Manager secret ID for SSL private key"
  value       = google_secret_manager_secret.ssl_key.secret_id
}

output "server_ca_cert" {
  description = "Server CA certificate"
  value       = google_sql_database_instance.primary.server_ca_cert[0].cert
  sensitive   = true
}