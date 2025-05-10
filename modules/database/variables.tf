variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "regions" {
  description = "List of GCP regions"
  type        = list(string)
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
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "network_id" {
  description = "VPC network ID for private IP"
  type        = string
}