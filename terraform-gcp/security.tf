// terraform-gcp/security.tf
resource "google_compute_firewall" "intra" {
  name    = "allow-intra"
  network = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["26257", "8080"]
  }
  source_ranges = [var.vpc_cidr]
}
resource "google_compute_firewall" "management" {
  name    = "allow-management"
  network = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
  source_ranges = [var.my_ip_address]
}
resource "google_compute_firewall" "application" {
  name    = "allow-application"
  network = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["8080", "8000", "3000"]
  }
  source_ranges = [var.my_ip_address]
}
resource "google_compute_firewall" "database" {
  name    = "allow-database"
  network = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["26257", "8080", "5432"]
  }
  source_ranges = [var.my_ip_address]
}
resource "google_compute_firewall" "kafka" {
  name    = "allow-kafka"
  network = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["8082-8083", "9021"]
  }
  source_ranges = [var.my_ip_address]
}

