variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "regions" {
  description = "List of GCP regions"
  type        = list(string)
}

variable "zones" {
  description = "Map of zones for each region"
  type        = map(list(string))
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