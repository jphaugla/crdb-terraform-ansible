# terraform-gcp/crdb.tf

# ——————————————————————————————————————————————————————————————————————————
# 2) one persistent disk in each zone
# ——————————————————————————————————————————————————————————————————————————
resource "google_compute_disk" "crdb_data" {
  count = var.crdb_nodes

  name = "crdb-data-${count.index}"
  size = var.crdb_store_volume_size
  type = var.crdb_store_volume_type
  zone = local.compute_zones[count.index]
}

# ——————————————————————————————————————————————————————————————————————————
# 3) one VM in each zone, attaching the matching disk
# ——————————————————————————————————————————————————————————————————————————
resource "google_compute_instance" "crdb" {
  count        = var.crdb_nodes
  name         = "crdb-${count.index}-${var.virtual_network_location}"
  machine_type = var.crdb_instance_type
  zone         = local.compute_zones[count.index]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.compute_image.self_link
      size  = var.crdb_store_volume_size
      type  = var.crdb_store_volume_type
    }
  }

  attached_disk {
    source      = google_compute_disk.crdb_data[count.index].id
    device_name = "sdb"
  }

  network_interface {
    # keeps your old .name references in inventory.tf happy
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main_subnet.name
    access_config {}
  }

  labels = merge(
    local.base_labels,
    { name = "${var.owner}-crdb-${count.index}-${var.virtual_network_location}" }
  )
}

