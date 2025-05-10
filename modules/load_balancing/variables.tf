variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "lb_name" {
  description = "Name for the load balancer resources"
  type        = string
}

variable "network" {
  description = "VPC network self link"
  type        = string
}

variable "regions" {
  description = "List of GCP regions"
  type        = list(string)
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

variable "instance_groups" {
  description = "Map of instance groups by type"
  type        = map(list(string))
}

variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
  default     = null
}