# Locals
locals {
  kafka_private_ip       = var.include_kafka == "yes" ? aws_instance.kafka[0].private_ip: "localhost"
  front_end_public_ip    = var.include_load_balancer == "yes" ? aws_lb.public_lb[0].dns_name : aws_instance.haproxy[0].public_ip
  front_end_private_ip   = var.include_load_balancer == "yes" ? aws_lb.private_lb[0].dns_name : aws_instance.haproxy[0].private_ip
}

# Dummy Resource (fallback)
resource "null_resource" "dummy" {}

# Conditional Resource Dependencies
resource "null_resource" "lb_dependencies" {
  count = var.include_load_balancer == "yes" ? 1 : 0
  depends_on = [
    aws_lb.public_lb,
    aws_lb.private_lb
  ]
}

resource "null_resource" "validation_check" {
  count = (
    var.include_load_balancer == "yes" || var.include_ha_proxy == "yes" ? 0 : 1
  )

  provisioner "local-exec" {
    command = "echo 'Validation Error: Either include_load_balancer or include_ha_proxy must be set to yes.' && exit 1"
  }
}

# Null Resource for Provisioning
resource "null_resource" "provision" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${var.playbook_working_directory}"
    command     = "ansible-playbook -i '${var.playbook_instances_inventory_file}' --private-key ${var.ssh_private_key} playbook.yml ${var.ansible_verbosity_switch} -e 'db_admin_user=${var.dbadmin_user_name}' -e 'db_admin_password=${var.dbadmin_user_password}' -e 'crdb_version=${var.crdb_version}' -e 'region=${var.virtual_network_location}' -e 'include_kafka=${var.include_kafka}' -e 'start_replicator=${var.start_replicator}' -e 'kafka_internal_ip=${local.kafka_private_ip}' -e 'prometheus_string=${local.prometheus_string}' -e 'prometheus_app_string=${local.prometheus_app_string}' -e 'join_string=${local.join_string}' -e 'full_path_license_directory=${var.full_path_license_directory}' -e 'allow_non_tls=${var.allow_non_tls}' -e 'crdb_file_location=${var.crdb_file_location}' -e 'login_username=${local.admin_username}' -e 'include_app=${var.include_app}' -e 'install_enterprise_keys=${var.install_enterprise_keys}' -e 'load_balancer_public_ip=${local.front_end_public_ip}' -e 'load_balancer_private_ip=${local.front_end_private_ip}'"
  }

  depends_on = [
    local_file.instances_file,
    aws_instance.haproxy,
    aws_instance.app,
    aws_instance.kafka,
    aws_instance.crdb,
    null_resource.lb_dependencies,
    null_resource.dummy
  ]
}
