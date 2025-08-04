// terraform-gcp/security.tf
resource "google_compute_firewall" "intra" {
  name    = "${var.project_name}-allow-intra-${var.virtual_network_location}"
  network    = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["26257", "8080", "9092"]
  }
  source_ranges = [var.vpc_cidr]
}

resource "google_compute_firewall" "management" {
  name    = "${var.project_name}-allow-management-${var.virtual_network_location}"
  network    = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
  source_ranges = concat(var.netskope_ips, ["${var.my_ip_address}/32"])
}

resource "google_compute_firewall" "application" {
  name    = "${var.project_name}-allow-application-${var.virtual_network_location}"
  network    = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["8080", "8000", "3000"]
  }
  source_ranges = concat(var.netskope_ips, ["${var.my_ip_address}/32"])
}

resource "google_compute_firewall" "database" {
  name    = "${var.project_name}-allow-database-${var.virtual_network_location}"
  network    = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["26257", "8080", "5432"]
  }
  source_ranges = concat(var.netskope_ips, ["${var.my_ip_address}/32"])
}

resource "google_compute_firewall" "kafka" {
  name    = "${var.project_name}-allow-kafka-${var.virtual_network_location}"
  network    = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["8082-8083", "9021"]
  }
  source_ranges = concat(var.netskope_ips, ["${var.my_ip_address}/32"])
}

