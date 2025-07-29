# terraform-gcp/app.tf

resource "google_compute_instance" "app" {
  count        = var.include_app == "yes" ? 1 : 0
  name         = "app-${count.index}-${var.virtual_network_location}"
  machine_type = var.app_instance_type
  zone         = local.first_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.compute_image.self_link
      size  = 100
      type  = "pd-standard"
    }
    # GCP always encrypts boot disks by default
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main_subnet.name
    access_config {}
  }

  labels = merge(
    local.base_labels,
    { name = "${var.owner}-app-${var.virtual_network_location}" }
  )
}

