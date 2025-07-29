# Locals for dynamic values
locals {
  kafka_private_ip     = var.include_kafka == "yes" ? google_compute_instance.kafka[0].network_interface[0].network_ip : "localhost"

  # point at HAProxy instead of a cloud LB
  front_end_public_ip  = google_compute_instance.haproxy[0].network_interface[0].access_config[0].nat_ip
  front_end_private_ip = google_compute_instance.haproxy[0].network_interface[0].network_ip

  admin_username       = "ubuntu"
}

# Dummy fallback
resource "null_resource" "dummy" {}

# No LB dependency needed for provisioning since we’re pointing at instance IPs directly
resource "null_resource" "lb_dependencies" {
  count      = 0
  depends_on = []
}

# Validation: require either LB or HAProxy
resource "null_resource" "validation_check" {
  count = (var.include_load_balancer == "yes" || var.include_ha_proxy == "yes") ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'Validation Error: Either include_load_balancer or include_ha_proxy must be set to yes.' && exit 1"
  }
}

# Null resource to run Ansible
resource "null_resource" "provision" {
  count = var.run_ansible ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    google_compute_instance.crdb,
    google_compute_instance.haproxy,
    google_compute_instance.kafka,
    local_file.instances_file,
    null_resource.validation_check,
    null_resource.dummy,
  ]

  provisioner "local-exec" {
    working_dir = var.playbook_working_directory

    command = <<EOF
ansible-playbook \
  -i "${var.playbook_instances_inventory_file}" \
  --private-key "${var.ssh_private_key}" \
  playbook.yml ${var.ansible_verbosity_switch} \
  -e db_admin_user="${var.dbadmin_user_name}" \
  -e db_admin_password="${var.dbadmin_user_password}" \
  -e crdb_version="${var.crdb_version}" \
  -e region="${var.virtual_network_location}" \
  -e include_kafka="${var.include_kafka}" \
  -e setup_migration="${var.setup_migration}" \
  -e kafka_internal_ip="${local.kafka_private_ip}" \
  -e prometheus_string="${local.prometheus_string}" \
  -e prometheus_app_string="${local.prometheus_app_string}" \
  -e join_string="${local.join_string}" \
  -e full_path_license_directory="${var.full_path_license_directory}" \
  -e allow_non_tls="${var.allow_non_tls}" \
  -e crdb_file_location="${var.crdb_file_location}" \
  -e login_username="${local.admin_username}" \
  -e kafka_username=ubuntu \
  -e include_app="${var.include_app}" \
  -e do_crdb_init="${var.do_crdb_init}" \
  -e install_enterprise_keys="${var.install_enterprise_keys}" \
  -e load_balancer_public_ip="${local.front_end_public_ip}" \
  -e load_balancer_private_ip="${local.front_end_private_ip}"
EOF
  }
}

