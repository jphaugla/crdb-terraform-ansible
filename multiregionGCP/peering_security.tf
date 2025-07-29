# multiregionGCP/peering_security.tf
# ───────────────────────────────────────────────────────────────────────────────
# Inter‑region CockroachDB firewall rules
# ───────────────────────────────────────────────────────────────────────────────

# Allow CRDB traffic into Region 0 from Regions 1 & 2
resource "google_compute_firewall" "allow_crdb_to_0" {
  provider     = google.region-0
  name    = "allow-crdb-to-0"
  network = module.crdb-region-0.network_name

  allow {
    protocol = "tcp"
    ports    = ["26257"]
  }

  source_ranges = [
    var.vpc_cidr_list[1],
    var.vpc_cidr_list[2],
  ]
}

# Allow CRDB traffic into Region 1 from Regions 0 & 2
resource "google_compute_firewall" "allow_crdb_to_1" {
  provider     = google.region-1
  name    = "allow-crdb-to-1"
  network = module.crdb-region-1.network_name

  allow {
    protocol = "tcp"
    ports    = ["26257"]
  }

  source_ranges = [
    var.vpc_cidr_list[0],
    var.vpc_cidr_list[2],
  ]
}

# Allow CRDB traffic into Region 2 from Regions 0 & 1
resource "google_compute_firewall" "allow_crdb_to_2" {
  provider     = google.region-2
  name    = "allow-crdb-to-2"
  network = module.crdb-region-2.network_name

  allow {
    protocol = "tcp"
    ports    = ["26257"]
  }

  source_ranges = [
    var.vpc_cidr_list[0],
    var.vpc_cidr_list[1],
  ]
}

