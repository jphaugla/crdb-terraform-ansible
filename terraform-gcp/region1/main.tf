// terraform-gcp/region1/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }

}

locals {
  project_name       = "cockroach-jhaugland"
  region             = "us-east1"
  credentials_file   = "~/.config/gcloud/application_default_credentials.json"
  ssh_private_key    = "~/.ssh/jph-cockroach-gcp"
  my_ip_address      = "162.222.52.25"
  vpc_cidr           = "192.168.3.0/24"
  owner              = "jhaug"
}

provider "google" {
  project     = local.project_name
  region      = local.region
  credentials = file(local.credentials_file)
}

module "my_gcp" {
  source                     = "../"
  my_ip_address              = local.my_ip_address
  virtual_network_location   = local.region
  owner                      = local.owner
  project_name               = local.project_name
  ssh_private_key            = local.ssh_private_key
  gcp_credentials_file       = local.credentials_file
  vpc_cidr                   = local.vpc_cidr

  # -----------------------------------------
  # CRDB Specifications
  # -----------------------------------------
  crdb_nodes                 = 3
  crdb_instance_type         = "e2-standard-4"
  crdb_store_volume_type     = "pd-standard"
  crdb_store_volume_size     = 200
  crdb_version               = "25.2.4"
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
  include_kafka               = "yes"
  # Kafka struggles with the 4 vcpu version
  kafka_instance_type         = "e2-standard-8"

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
}

