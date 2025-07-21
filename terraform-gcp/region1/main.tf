// terraform-gcp/region1/main.tf

module "my_gcp" {
  source                     = "../"
  my_ip_address              = "174.141.204.193"
  virtual_network_location   = "us-central1"
  owner                      = "jhaug"
  project_name               = "cockroach-jhaugland"
  crdb_instance_key_name     = "jph-cockroach-us-central1"
  ssh_private_key            = "~/.ssh/jph-cockroach-us-central1"
  vpc_cidr                   = "192.168.6.0/24"

  # -----------------------------------------
  # CRDB Specifications
  # -----------------------------------------
  crdb_nodes                 = 3
  crdb_instance_type         = "e2-standard-4"
  crdb_store_volume_type     = "pd-standard"
  crdb_store_volume_size     = 200
  crdb_version               = "25.2.0"
  crdb_arm_release           = "yes"
  crdb_enable_spot_instances = "no"
  crdb_file_location         = "/mnt/data"

  # ----------------------------------------
  # Cluster Location Data - For console map
  # ----------------------------------------
  install_system_location_data = "yes"

  # ----------------------------------------
  # Allow non-TLS connections
  # ----------------------------------------
  allow_non_tls                = true

  # ----------------------------------------
  # HA Proxy
  # ----------------------------------------
  include_ha_proxy            = "yes"
  haproxy_instance_type      = "e2-standard-4"

  # ----------------------------------------
  # Kafka
  # ----------------------------------------
  include_kafka               = "no"
  kafka_instance_type         = "e2-standard-4"

  # ----------------------------------------
  # APP Node
  # ----------------------------------------
  include_app                 = "yes"
  app_instance_type           = "e2-standard-4"
  create_dbadmin_user         = "yes"
  setup_migration             = "yes"
  dbadmin_user_name           = "jhaugland"
  dbadmin_user_password       = "jasonrocks"

  # ----------------------------------------
  # Cluster Enterprise License Keys
  # ----------------------------------------
  install_enterprise_keys      = "no"
  cluster_organization         = ""
  enterprise_license           = ""

  # ----------------------------------------
  # Create Network load balancer
  # ----------------------------------------
# load balancer does not work yet on gcp
  include_load_balancer        = "no"
  full_path_license_directory = "/Users/jasonhaugland/.crdb/"
  run_ansible                  = true
  gcp_credentials_file = "/Users/jasonhaugland/.config/gcloud/application_default_credentials.json"
}

