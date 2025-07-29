// terraform-gcp/terraform.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}
# single, un‑aliased provider for standalone use
provider "google" {
  project     = var.project_name
  region      = var.virtual_network_location
  credentials = file(var.gcp_credentials_file)
}
