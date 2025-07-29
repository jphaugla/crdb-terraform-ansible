data "google_compute_zones" "available" {
  region = var.virtual_network_location
}
locals {
  join_string = (var.join_string != "" ? var.join_string : join(",", google_compute_instance.crdb[*].network_interface[0].network_ip))
  ip_list_public     = join(" ", google_compute_instance.crdb[*].network_interface[0].network_ip)
  join_string_public = (var.join_string != "" ? var.join_string : join(",", google_compute_instance.crdb[*].network_interface[0].access_config[0].nat_ip))
  prometheus_string = (var.prometheus_string != "" ? var.prometheus_string : join(",", formatlist("%s:8080", google_compute_instance.crdb[*].network_interface[0].network_ip)))
  prometheus_app_string = (var.prometheus_app_string != "" ? var.prometheus_app_string : join(",", formatlist("%s:30005", google_compute_instance.crdb[*].network_interface[0].network_ip)))
  #
  # build the full zone names in order, e.g. ["us-central1-a", ...]
  compute_zones = slice(
    data.google_compute_zones.available.names,
    0,
    var.crdb_nodes
  )

  # first_zone for single-instance pieces (haproxy, app, kafka, etc)
  first_zone = local.compute_zones[0]

  # Common labels
  base_labels = {
    environment = var.virtual_network_location
    owner       = var.owner
  }
}

data "google_compute_image" "compute_image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

