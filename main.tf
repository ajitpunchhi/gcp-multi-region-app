# Configure the Google Provider
provider "google" {
  project = var.project_id
}

# Merge default labels with environment label
locals {
  common_labels = merge(
    var.labels,
    {
      environment = var.environment
    }
  )
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_id   = var.project_id
  network_name = var.network_name
  regions      = var.regions
  zones        = var.zones
  environment  = var.environment
  labels       = local.common_labels
}

# DNS Module
module "dns" {
  source = "./modules/dns"

  count = var.enable_cloud_dns ? 1 : 0

  project_id    = var.project_id
  dns_zone_name = var.dns_zone_name
  domain_name   = var.domain_name
  lb_ip_address = module.load_balancer.lb_ip_address
  environment   = var.environment
  labels        = local.common_labels
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load-balancer"

  project_id  = var.project_id
  lb_name     = var.lb_name
  network     = module.networking.network_self_link
  regions     = var.regions
  environment = var.environment
  labels      = local.common_labels

  # Instance groups from compute module
  instance_groups = module.compute.instance_groups
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_id            = var.project_id
  network               = module.networking.network_self_link
  subnetworks           = module.networking.subnetworks
  zones                 = var.zones
  instance_group_configs = var.instance_group_configs
  environment           = var.environment
  labels                = local.common_labels
}

# Database Module
module "database" {
  source = "./modules/database"

  count = var.enable_cloud_sql ? 1 : 0

  project_id   = var.project_id
  regions      = var.regions
  sql_configs  = var.sql_configs
  environment  = var.environment
  labels       = local.common_labels
  
  # Network dependency
  network_id = module.networking.network_self_link
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  count = var.enable_cloud_storage ? 1 : 0

  project_id      = var.project_id
  storage_configs = var.storage_configs
  environment     = var.environment
  labels          = local.common_labels
}