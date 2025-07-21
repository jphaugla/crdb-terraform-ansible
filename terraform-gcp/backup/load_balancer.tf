###########
# load_balancer.tf
###########

# 1) Zonal instance-group per CRDB VM
resource "google_compute_instance_group" "crdb_group" {
  for_each = toset(local.crdb_zones)

  name = "crdb-group-${each.key}"  
  zone = each.key

  instances = [
    for idx, inst in google_compute_instance.crdb :
    inst.self_link if local.crdb_zones[idx] == each.key
  ]
}

# 2) TCP health check
resource "google_compute_health_check" "crdb" {
  name                = "crdb-tcp-hc"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 3
  unhealthy_threshold = 3

  tcp_health_check {
    port = 26257
  }
}

# 3) GLOBAL backend service for INTERNAL self-managed TCP
resource "google_compute_backend_service" "crdb" {
  name                    = "crdb-backend"
  protocol                = "TCP"
  timeout_sec             = 10
  load_balancing_scheme   = "INTERNAL_SELF_MANAGED"

  dynamic "backend" {
    for_each = google_compute_instance_group.crdb_group
    content {
      group = backend.value.self_link
    }
  }

  health_checks = [
    google_compute_health_check.crdb.self_link
  ]
}

# 4) Internal forwarding rule
resource "google_compute_forwarding_rule" "crdb_internal" {
  name                  = "crdb-internal-lb"
  region                = var.virtual_network_location
  load_balancing_scheme = "INTERNAL_SELF_MANAGED"
  backend_service       = google_compute_backend_service.crdb.self_link

  network    = google_compute_network.main.self_link
  subnetwork = google_compute_subnetwork.main_subnet.self_link

  port_range = "26257"
}
