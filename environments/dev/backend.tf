# Backend configuration for Development environment
terraform {
  backend "gcs" {
    bucket  = "your-terraform-state-bucket"
    prefix  = "environments/dev"
  }
}

# Provider configuration for dev
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# Enable required APIs for dev
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "dns.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "pubsub.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ])

  service = each.key
  project = var.project_id

  disable_on_destroy = false
}