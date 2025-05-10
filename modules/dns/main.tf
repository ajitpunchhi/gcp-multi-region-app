# Cloud DNS Zone
resource "google_dns_managed_zone" "default" {
  name        = var.dns_zone_name
  dns_name    = "${var.domain_name}."
  description = "DNS zone for ${var.environment} environment"
  project     = var.project_id

  labels = var.labels
}

# A record pointing to the load balancer IP
resource "google_dns_record_set" "a" {
  name         = google_dns_managed_zone.default.dns_name
  managed_zone = google_dns_managed_zone.default.name
  type         = "A"
  ttl          = 300
  project      = var.project_id

  rrdatas = [var.lb_ip_address]
}

# WWW CNAME record
resource "google_dns_record_set" "www" {
  name         = "www.${google_dns_managed_zone.default.dns_name}"
  managed_zone = google_dns_managed_zone.default.name
  type         = "CNAME"
  ttl          = 300
  project      = var.project_id

  rrdatas = [google_dns_managed_zone.default.dns_name]
}

# MX records (if needed)
resource "google_dns_record_set" "mx" {
  name         = google_dns_managed_zone.default.dns_name
  managed_zone = google_dns_managed_zone.default.name
  type         = "MX"
  ttl          = 3600
  project      = var.project_id

  rrdatas = var.mx_records
}

# TXT records (including SPF)
resource "google_dns_record_set" "txt" {
  for_each = var.txt_records

  name         = "${each.key}.${google_dns_managed_zone.default.dns_name}"
  managed_zone = google_dns_managed_zone.default.name
  type         = "TXT"
  ttl          = 300
  project      = var.project_id

  rrdatas = [each.value]
}