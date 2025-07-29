# terraform-gcp/kafka.tf

resource "google_compute_instance" "kafka" {
  count        = var.include_kafka == "yes" ? 1 : 0
  name         = "kafka-${count.index}-${var.virtual_network_location}"
  machine_type = var.kafka_instance_type
  zone         = local.first_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.compute_image.self_link
      size  = 50
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
    { name = "${var.owner}-kafka-${var.virtual_network_location}" }
  )
}

