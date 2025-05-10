variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "network" {
  description = "VPC network self link"
  type        = string
}

variable "subnetworks" {
  description = "Map of subnetworks"
  type = map(object({
    id        = string
    self_link = string
    region    = string
    cidr      = string
  }))
}

variable "zones" {
  description = "Map of zones for each region"
  type        = map(list(string))
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

variable "primary_region" {
  description = "Primary region for instance groups"
  type        = string
  default     = "us-central1"
}