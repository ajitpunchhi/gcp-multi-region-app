variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "regions" {
  description = "List of GCP regions for deployment"
  type        = list(string)
  default     = ["us-central1", "us-west1"]
}

variable "zones" {
  description = "Map of zones for each region"
  type        = map(list(string))
  default = {
    "us-central1" = ["us-central1-a", "us-central1-b"]
    "us-west1"    = ["us-west1-a", "us-west1-b"]
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "multi-region-network"
}

variable "enable_cloud_dns" {
  description = "Enable Cloud DNS configuration"
  type        = bool
  default     = true
}

variable "dns_zone_name" {
  description = "Cloud DNS zone name"
  type        = string
  default     = "multi-region-zone"
}

variable "domain_name" {
  description = "Domain name for DNS zone"
  type        = string
}

variable "lb_name" {
  description = "Name for the load balancer"
  type        = string
  default     = "multi-region-lb"
}

variable "instance_group_configs" {
  description = "Configuration for instance groups"
  type = map(object({
    machine_type     = string
    instances_count  = number
    disk_size        = number
    disk_type        = string
    image_family     = string
    image_project    = string
  }))
  default = {
    "web" = {
      machine_type     = "e2-standard-2"
      instances_count  = 2
      disk_size        = 20
      disk_type        = "pd-standard"
      image_family     = "ubuntu-2004-lts"
      image_project    = "ubuntu-os-cloud"
    }
    "app" = {
      machine_type     = "e2-standard-4"
      instances_count  = 2
      disk_size        = 50
      disk_type        = "pd-ssd"
      image_family     = "ubuntu-2004-lts"
      image_project    = "ubuntu-os-cloud"
    }
  }
}

variable "enable_cloud_sql" {
  description = "Enable Cloud SQL instances"
  type        = bool
  default     = true
}

variable "sql_configs" {
  description = "Cloud SQL configuration"
  type = map(object({
    database_version = string
    tier            = string
    disk_size       = number
    backup_enabled  = bool
    ha_enabled      = bool
  }))
  default = {
    "primary" = {
      database_version = "POSTGRES_14"
      tier            = "db-custom-2-8192"
      disk_size       = 100
      backup_enabled  = true
      ha_enabled      = true
    }
    "replica" = {
      database_version = "POSTGRES_14"
      tier            = "db-custom-2-8192"
      disk_size       = 100
      backup_enabled  = false
      ha_enabled      = false
    }
  }
}

variable "enable_cloud_storage" {
  description = "Enable Cloud Storage buckets"
  type        = bool
  default     = true
}

variable "storage_configs" {
  description = "Cloud Storage bucket configurations"
  type = map(object({
    location      = string
    storage_class = string
    versioning    = bool
  }))
  default = {
    "primary" = {
      location      = "US-CENTRAL1"
      storage_class = "STANDARD"
      versioning    = true
    }
    "secondary" = {
      location      = "US-WEST1"
      storage_class = "STANDARD"
      versioning    = true
    }
  }
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    terraform   = "true"
    environment = "unset"
  }
}