################################################################################
# peering_gcp.tf
#
# Simplified VPC peering for 3-region CockroachDB on GCP.
# We let GCP auto‑propagate routes—no google_compute_route resources needed.
################################################################################

# ───────────────────────────────────────────────────────────────────────────────
# Region 0 ↔ Region 1 Peering
# ───────────────────────────────────────────────────────────────────────────────
resource "google_compute_network_peering" "peer0_to_1" {
  name              = "peer0-to-1"
  network           = module.crdb-region-0.network_self_link
  peer_network      = module.crdb-region-1.network_self_link

  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_network_peering" "peer1_to_0" {
  name              = "peer1-to-0"
  network           = module.crdb-region-1.network_self_link
  peer_network      = module.crdb-region-0.network_self_link

  import_custom_routes = true
  export_custom_routes = true
}

# ───────────────────────────────────────────────────────────────────────────────
# Region 1 ↔ Region 2 Peering
# ───────────────────────────────────────────────────────────────────────────────
resource "google_compute_network_peering" "peer1_to_2" {
  name              = "peer1-to-2"
  network           = module.crdb-region-1.network_self_link
  peer_network      = module.crdb-region-2.network_self_link

  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_network_peering" "peer2_to_1" {
  name              = "peer2-to-1"
  network           = module.crdb-region-2.network_self_link
  peer_network      = module.crdb-region-1.network_self_link

  import_custom_routes = true
  export_custom_routes = true
}

# ───────────────────────────────────────────────────────────────────────────────
# Region 2 ↔ Region 0 Peering
# ───────────────────────────────────────────────────────────────────────────────
resource "google_compute_network_peering" "peer2_to_0" {
  name              = "peer2-to-0"
  network           = module.crdb-region-2.network_self_link
  peer_network      = module.crdb-region-0.network_self_link

  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_network_peering" "peer0_to_2" {
  name              = "peer0-to-2"
  network           = module.crdb-region-0.network_self_link
  peer_network      = module.crdb-region-2.network_self_link

  import_custom_routes = true
  export_custom_routes = true
}
