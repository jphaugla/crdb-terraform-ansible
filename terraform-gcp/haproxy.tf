# terraform-gcp/haproxy.tf

resource "google_compute_instance" "haproxy" {
  count        = var.include_ha_proxy == "yes" ? 1 : 0
  name         = "haproxy-0-${var.virtual_network_location}"
  machine_type = var.haproxy_instance_type
  zone         = local.first_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.compute_image.self_link
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main_subnet.name
    access_config {}
  }

  labels = merge(
    local.base_labels,
    { name = "${var.owner}-haproxy-${var.virtual_network_location}" }
  )
}

