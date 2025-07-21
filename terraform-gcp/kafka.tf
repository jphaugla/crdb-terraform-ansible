// terraform-gcp/kafka.tf
data "google_compute_image" "kafka_image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}
resource "google_compute_instance" "kafka" {
  count        = var.include_kafka == "yes" ? 1 : 0
  name         = "kafka-0"
  machine_type = var.kafka_instance_type
  zone         = "${var.virtual_network_location}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.kafka_image.self_link
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
    local.labels,
    { name = "${var.owner}-haproxy-${count.index}" }
  )

}

