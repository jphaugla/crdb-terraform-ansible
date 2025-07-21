
// terraform-gcp/storage.tf
resource "google_storage_bucket" "molt_bucket" {
  name          = "${var.project_name}-molt-bucket"
  location      = var.virtual_network_location
  force_destroy = true
}
resource "google_service_account" "storage_sa" {
  account_id   = "molt-storage-sa"
  display_name = "MOLT Storage Service Account"
}
resource "google_storage_bucket_iam_member" "bucket_admin" {
  bucket = google_storage_bucket.molt_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.storage_sa.email}"
}

