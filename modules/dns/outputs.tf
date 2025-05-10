output "zone_id" {
  description = "DNS zone ID"
  value       = google_dns_managed_zone.default.id
}

output "zone_name" {
  description = "DNS zone name"
  value       = google_dns_managed_zone.default.name
}

output "name_servers" {
  description = "DNS zone name servers"
  value       = google_dns_managed_zone.default.name_servers
}

output "dns_name" {
  description = "DNS zone fully qualified domain name"
  value       = google_dns_managed_zone.default.dns_name
}