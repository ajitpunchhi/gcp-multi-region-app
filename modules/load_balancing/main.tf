# Global HTTP load balancer (external)
resource "google_compute_global_address" "default" {
  name    = "${var.lb_name}-ip"
  project = var.project_id
}

# Backend service for web instances
resource "google_compute_backend_service" "web" {
  name        = "${var.lb_name}-web-backend"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30
  project     = var.project_id

  enable_cdn = true

  dynamic "backend" {
    for_each = var.instance_groups["web"]
    content {
      group           = backend.value
      balancing_mode  = "UTILIZATION"
      capacity_scaler = 1.0
    }
  }

  health_checks = [google_compute_health_check.web.id]

  cdn_policy {
    cache_mode       = "CACHE_ALL_STATIC"
    default_ttl      = 3600
    max_ttl          = 86400
    negative_caching = true
  }
}

# Health check for web instances
resource "google_compute_health_check" "web" {
  name               = "${var.lb_name}-web-health-check"
  check_interval_sec = 5
  timeout_sec        = 3
  project            = var.project_id

  http_health_check {
    port               = 80
    request_path       = "/health"
    proxy_header       = "PROXY_V1"
  }
}

# URL map for routing traffic
resource "google_compute_url_map" "default" {
  name            = "${var.lb_name}-url-map"
  default_service = google_compute_backend_service.web.id
  project         = var.project_id

  host_rule {
    hosts        = ["*"]
    path_matcher = "default"
  }

  path_matcher {
    name            = "default"
    default_service = google_compute_backend_service.web.id
  }
}

# HTTP target proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.lb_name}-http-proxy"
  url_map = google_compute_url_map.default.id
  project = var.project_id
}

# HTTPS target proxy (if SSL certificates are provided)
resource "google_compute_target_https_proxy" "default" {
  name             = "${var.lb_name}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
  project          = var.project_id
}

# Managed SSL certificate (requires a domain name)
resource "google_compute_managed_ssl_certificate" "default" {
  name    = "${var.lb_name}-ssl-cert"
  project = var.project_id

  managed {
    domains = [var.domain_name != null ? var.domain_name : "example.com"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Global forwarding rule for HTTP
resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.lb_name}-http-forwarding-rule"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
  ip_address = google_compute_global_address.default.address
  project    = var.project_id
}

# Global forwarding rule for HTTPS
resource "google_compute_global_forwarding_rule" "https" {
  name       = "${var.lb_name}-https-forwarding-rule"
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = google_compute_global_address.default.address
  project    = var.project_id
}