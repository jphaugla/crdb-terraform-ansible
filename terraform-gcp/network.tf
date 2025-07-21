// terraform-gcp/network.tf
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main_subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.vpc_cidr
  region        = var.virtual_network_location
  network       = google_compute_network.main.id
}
