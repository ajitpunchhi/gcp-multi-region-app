terraform {
  required_version = ">= 1.4.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
  
  backend "gcs" {
    bucket = "terraform-state-my-gcp-project"
    prefix = "multi-region-app"
  }
}

provider "google" {
  project = var.project_id
  region  = var.regions[0]
}

provider "google-beta" {
  project = var.project_id
  region  = var.regions[0]
}