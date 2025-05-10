variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "storage_configs" {
  description = "Cloud Storage bucket configurations"
  type = map(object({
    location      = string
    storage_class = string
    versioning    = bool
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

variable "notifications_publisher_sa" {
  description = "Service account email for Pub/Sub notifications publisher"
  type        = string
  default     = "service-project-number@gs-project-accounts.iam.gserviceaccount.com"
}