output "lb_ip_address" {
  description = "IP address of the global load balancer"
  value       = google_compute_global_address.default.address
}

output "lb_url_map" {
  description = "URL map ID"
  value       = google_compute_url_map.default.id
}

output "backend_services" {
  description = "Backend services created"
  value = {
    web = google_compute_backend_service.web.id
  }
}

output "health_checks" {
  description = "Health checks created"
  value = {
    web = google_compute_health_check.web.id
  }
}

output "ssl_certificate" {
  description = "Managed SSL certificate ID"
  value       = google_compute_managed_ssl_certificate.default.id
}

output "forwarding_rules" {
  description = "Forwarding rules created"
  value = {
    http  = google_compute_global_forwarding_rule.http.id
    https = google_compute_global_forwarding_rule.https.id
  }
}