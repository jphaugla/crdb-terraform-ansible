// terraform-gcp/app.tf

resource "google_compute_instance" "app" {
  count        = (var.include_app == "yes" && var.create_ec2_instances == "yes") ? 1 : 0
  name         = "app-${count.index}"
  machine_type = var.app_instance_type
  zone         = "${var.virtual_network_location}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.app_image.self_link
      size  = 100
      type  = "pd-standard"
    }
    # GCP always encrypts boot disks
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main_subnet.name
    access_config {}
  }
  labels = merge(
    local.labels,
    { name = "${var.owner}-haproxy-${count.index}" }
  )
}

// Data source for app image
data "google_compute_image" "app_image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

