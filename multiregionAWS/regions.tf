module "crdb-region-0" {
  source    = "../terraform-aws"
  providers = { aws = aws.region-0 }

  # ─── Required inputs ───
  my_ip_address              = var.my_ip_address
  virtual_network_location   = var.aws_region_list[0]
  owner                      = var.owner
  project_name               = var.project_name
  crdb_instance_key_name     = var.aws_instance_keys[0]
  ssh_private_key            = var.ssh_private_key_list[0]
  vpc_cidr                   = var.vpc_cidr_list[0]
  aws_region_list            = var.aws_region_list

  # ──────────────────────────────────────────────────────────────────────────
  # ANSIBLE / INVENTORY PATH OVERRIDES
  # ──────────────────────────────────────────────────────────────────────────

  instances_inventory_file           = "../../terraform-aws/inventory-${var.aws_region_list[0]}"
  playbook_working_directory         = "../../ansible"
  playbook_instances_inventory_file  = "../terraform-aws/inventory-${var.aws_region_list[0]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"

  # ─── CRDB specs ───
  crdb_nodes                 = var.crdb_nodes
  crdb_instance_type         = var.crdb_instance_type
  crdb_store_volume_type     = var.crdb_store_volume_type
  crdb_store_volume_size     = var.crdb_store_volume_size
  crdb_version               = var.crdb_version
  crdb_arm_release           = var.crdb_arm_release
  crdb_enable_spot_instances = var.crdb_enable_spot_instances
  crdb_file_location         = var.crdb_file_location

  # ─── Cluster location ───
  install_system_location_data = var.install_system_location_data
  allow_non_tls                = var.allow_non_tls

  # ─── HAProxy ───
  include_ha_proxy          = var.include_ha_proxy
  haproxy_instance_type     = var.haproxy_instance_type

  # ─── Kafka ───
  include_kafka             = var.include_kafka
  kafka_instance_type       = var.kafka_instance_type

  # ─── App node ───
  include_app               = var.include_app
  app_instance_type         = var.app_instance_type
  create_dbadmin_user       = var.create_dbadmin_user
  setup_migration           = var.setup_migration
  dbadmin_user_name         = var.dbadmin_user_name
  dbadmin_user_password     = var.dbadmin_user_password

  # ─── Licensing ───
  full_path_license_directory = var.full_path_license_directory

  # ─── Load Balancer ───
  include_load_balancer     = var.include_load_balancer
}

module "crdb-region-1" {
  source    = "../terraform-aws"
  providers = { aws = aws.region-1 }

  my_ip_address              = var.my_ip_address
  virtual_network_location   = var.aws_region_list[1]
  owner                      = var.owner
  project_name               = var.project_name
  crdb_instance_key_name     = var.aws_instance_keys[1]
  ssh_private_key            = var.ssh_private_key_list[1]
  vpc_cidr                   = var.vpc_cidr_list[1]
  aws_region_list            = var.aws_region_list
  join_string                = module.crdb-region-0.join_string

  # ──────────────────────────────────────────────────────────────────────────
  # ANSIBLE / INVENTORY PATH OVERRIDES
  # ──────────────────────────────────────────────────────────────────────────

  instances_inventory_file           = "../../terraform-aws/inventory-${var.aws_region_list[1]}"
  playbook_working_directory         = "../../ansible"
  playbook_instances_inventory_file  = "../terraform-aws/inventory-${var.aws_region_list[1]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"

  crdb_nodes                 = var.crdb_nodes
  crdb_instance_type         = var.crdb_instance_type
  crdb_store_volume_type     = var.crdb_store_volume_type
  crdb_store_volume_size     = var.crdb_store_volume_size
  crdb_version               = var.crdb_version
  crdb_arm_release           = var.crdb_arm_release
  crdb_enable_spot_instances = var.crdb_enable_spot_instances
  crdb_file_location         = var.crdb_file_location

  install_system_location_data = var.install_system_location_data
  allow_non_tls                = var.allow_non_tls

  include_ha_proxy          = var.include_ha_proxy
  haproxy_instance_type     = var.haproxy_instance_type

  include_kafka             = var.include_kafka
  kafka_instance_type       = var.kafka_instance_type

  include_app               = var.include_app
  app_instance_type         = var.app_instance_type
  create_dbadmin_user       = var.create_dbadmin_user
  setup_migration           = var.setup_migration
  dbadmin_user_name         = var.dbadmin_user_name
  dbadmin_user_password     = var.dbadmin_user_password

  full_path_license_directory = var.full_path_license_directory

  include_load_balancer     = var.include_load_balancer
}

module "crdb-region-2" {
  source    = "../terraform-aws"
  providers = { aws = aws.region-2 }

  my_ip_address              = var.my_ip_address
  virtual_network_location   = var.aws_region_list[2]
  owner                      = var.owner
  project_name               = var.project_name
  crdb_instance_key_name     = var.aws_instance_keys[2]
  ssh_private_key            = var.ssh_private_key_list[2]
  vpc_cidr                   = var.vpc_cidr_list[2]
  aws_region_list            = var.aws_region_list
  join_string                = module.crdb-region-0.join_string
  # ──────────────────────────────────────────────────────────────────────────
  # ANSIBLE / INVENTORY PATH OVERRIDES
  # ──────────────────────────────────────────────────────────────────────────

  instances_inventory_file           = "../../terraform-aws/inventory-${var.aws_region_list[2]}"
  playbook_working_directory         = "../../ansible"
  playbook_instances_inventory_file  = "../terraform-aws/inventory-${var.aws_region_list[2]}"
  instances_inventory_directory      = "temp"
  inventory_template_file            = "templates/inventory.tpl"

  crdb_nodes                 = var.crdb_nodes
  crdb_instance_type         = var.crdb_instance_type
  crdb_store_volume_type     = var.crdb_store_volume_type
  crdb_store_volume_size     = var.crdb_store_volume_size
  crdb_version               = var.crdb_version
  crdb_arm_release           = var.crdb_arm_release
  crdb_enable_spot_instances = var.crdb_enable_spot_instances
  crdb_file_location         = var.crdb_file_location

  install_system_location_data = var.install_system_location_data
  allow_non_tls                = var.allow_non_tls

  include_ha_proxy          = var.include_ha_proxy
  haproxy_instance_type     = var.haproxy_instance_type

  include_kafka             = var.include_kafka
  kafka_instance_type       = var.kafka_instance_type

  include_app               = var.include_app
  app_instance_type         = var.app_instance_type
  create_dbadmin_user       = var.create_dbadmin_user
  setup_migration           = var.setup_migration
  dbadmin_user_name         = var.dbadmin_user_name
  dbadmin_user_password     = var.dbadmin_user_password

  full_path_license_directory = var.full_path_license_directory

  include_load_balancer     = var.include_load_balancer
}

