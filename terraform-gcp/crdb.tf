// terraform-gcp/crdb.tf

data "google_compute_image" "crdb_image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

locals {
  # Distribute CRDB nodes across zones a, b, c
  crdb_zones = [
    for idx in range(var.crdb_nodes) : "${var.virtual_network_location}-${element(["a","b","c"], idx)}"
  ]
  # example existing labels map
  labels = {
    environment = var.virtual_network_location
    owner       = var.owner
  }
}

resource "google_compute_disk" "crdb_data" {
  count = var.crdb_nodes
  name  = "crdb-data-${count.index}"
  size  = var.crdb_store_volume_size
  type  = var.crdb_store_volume_type
  zone  = local.crdb_zones[count.index]
}

resource "google_compute_instance" "crdb" {
  count        = var.crdb_nodes
  name         = "crdb-${count.index}"
  machine_type = var.crdb_instance_type
  zone         = local.crdb_zones[count.index]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.crdb_image.self_link
      size  = var.crdb_store_volume_size
      type  = "pd-standard"
    }
  }
  attached_disk {
    source      = google_compute_disk.crdb_data[count.index].id
    device_name = "sdb"
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main_subnet.name
    access_config {}
  }
  labels = merge(
    local.labels,
    { name = "${var.owner}-crdb-${count.index}" }
  )

}


