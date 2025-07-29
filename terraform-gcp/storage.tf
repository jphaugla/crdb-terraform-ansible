// terraform-gcp/storage.tf

resource "google_storage_bucket" "molt_bucket" {
  name          = "${var.project_name}-molt-bucket-${var.virtual_network_location}"
  location      = var.virtual_network_location
  force_destroy = true
}

