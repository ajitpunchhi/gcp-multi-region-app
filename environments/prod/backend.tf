# Backend configuration for Production environment
terraform {
  backend "gcs" {
    bucket  = "your-terraform-state-bucket"
    prefix  = "environments/prod"
    
    # Optional: Enable versioning on the state bucket
    # Optional: Configure customer-managed encryption key
    # encryption_key = "projects/your-project/locations/global/keyRings/terraform-state/cryptoKeys/terraform-state-key"
    
    # Optional: Configure object prefix for state locking
    # state_locking = true
  }
}

# Provider configuration for production
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# Optional: Configure additional providers for different regions
provider "google" {
  alias   = "us-west1"
  project = var.project_id
  region  = "us-west1"
}

# Enable required APIs for production
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
    "logging.googleapis.com",
    "cloudtrace.googleapis.com"
  ])

  service = each.key
  project = var.project_id

  disable_on_destroy = false
}