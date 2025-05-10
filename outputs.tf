output "network_id" {
  description = "ID of the VPC network"
  value       = module.networking.network_id
}

output "subnetworks" {
  description = "Subnetworks created across regions"
  value       = module.networking.subnetworks
}

output "load_balancer_ip" {
  description = "Load balancer IP address"
  value       = module.load_balancer.lb_ip_address
}

output "dns_zone_name_servers" {
  description = "DNS zone name servers"
  value       = var.enable_cloud_dns ? module.dns[0].name_servers : null
}

output "instance_groups" {
  description = "Created instance groups"
  value       = module.compute.instance_groups
}

output "sql_instance_names" {
  description = "Cloud SQL instance names"
  value       = var.enable_cloud_sql ? module.database[0].sql_instance_names : null
}

output "storage_bucket_names" {
  description = "Cloud Storage bucket names"
  value       = var.enable_cloud_storage ? module.storage[0].bucket_names : null
}

output "project_id" {
  description = "The project ID used for all resources"
  value       = var.project_id
}

output "environment" {
  description = "The environment name"
  value       = var.environment
}