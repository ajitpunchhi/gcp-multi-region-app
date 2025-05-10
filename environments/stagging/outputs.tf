# Outputs for staging environment
output "infrastructure_outputs" {
  description = "All infrastructure outputs"
  value       = module.multi_region_infrastructure
}

output "load_balancer_ip" {
  description = "Load balancer IP address"
  value       = module.multi_region_infrastructure.load_balancer_ip
}

output "dns_nameservers" {
  description = "DNS zone nameservers"
  value       = module.multi_region_infrastructure.dns_zone_name_servers
}