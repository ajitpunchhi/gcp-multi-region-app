# Variables for prod environment
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "prod-network"
}

variable "regions" {
  description = "GCP regions for deployment"
  type        = list(string)
  default     = ["us-central1", "us-west1"]
}

variable "zones" {
  description = "Availability zones per region"
  type        = map(list(string))
  default = {
    "us-central1" = ["us-central1-a", "us-central1-b"]
    "us-west1"    = ["us-west1-a", "us-west1-b"]
  }
}

variable "enable_cloud_dns" {
  description = "Enable Cloud DNS"
  type        = bool
  default     = true
}

variable "dns_zone_name" {
  description = "DNS zone name"
  type        = string
  default     = "prod-zone"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "lb_name" {
  description = "Load balancer name"
  type        = string
  default     = "prod-lb"
}

variable "instance_group_configs" {
  description = "Instance group configurations"
  type = map(object({
    machine_type     = string
    instances_count  = number
    disk_size        = number
    disk_type        = string
    image_family     = string
    image_project    = string
  }))
}

variable "enable_cloud_sql" {
  description = "Enable Cloud SQL"
  type        = bool
  default     = true
}

variable "sql_configs" {
  description = "Cloud SQL configurations"
  type = map(object({
    database_version = string
    tier            = string
    disk_size       = number
    backup_enabled  = bool
    ha_enabled      = bool
  }))
}

variable "enable_cloud_storage" {
  description = "Enable Cloud Storage"
  type        = bool
  default     = true
}

variable "storage_configs" {
  description = "Storage configurations"
  type = map(object({
    location      = string
    storage_class = string
    versioning    = bool
  }))
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default = {
    terraform   = "true"
    environment = "prod"
    managed-by  = "terraform"
  }
}