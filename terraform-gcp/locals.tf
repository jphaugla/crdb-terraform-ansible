locals {
  join_string = (var.join_string != "" ? var.join_string : join(",", google_compute_instance.crdb[*].network_interface[0].network_ip))
  ip_list_public     = join(" ", google_compute_instance.crdb[*].network_interface[0].network_ip)
  join_string_public = (var.join_string != "" ? var.join_string : join(",", google_compute_instance.crdb[*].network_interface[0].access_config[0].nat_ip))
  prometheus_string = (var.prometheus_string != "" ? var.prometheus_string : join(",", formatlist("%s:8080", google_compute_instance.crdb[*].network_interface[0].network_ip)))
  prometheus_app_string = (var.prometheus_app_string != "" ? var.prometheus_app_string : join(",", formatlist("%s:30005", google_compute_instance.crdb[*].network_interface[0].network_ip)))
}
