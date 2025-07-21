// terraform-gcp/haproxy.tf
data "google_compute_image" "haproxy_image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}
resource "google_compute_instance" "haproxy" {
  count        = var.include_ha_proxy == "yes" ? 1 : 0
  name         = "haproxy-0"
  machine_type = var.haproxy_instance_type
  zone         = "${var.virtual_network_location}-a"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.haproxy_image.self_link
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
    local.labels,
    { name = "${var.owner}-haproxy-${count.index}" }
  )

}
