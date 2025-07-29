###############################################################################
# multipregionGCP/test/main.tf
#
# Driver for multiregionGCP. Supplies exactly the list‐typed inputs that
# multiregionGCP/variables.tf now declares, including crdb_instance_key_name
# (a list of three key names) instead of a single crdb_instance_key_name.
###############################################################################
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
  credentials_file   = "~/.config/gcloud/application_default_credentials.json"
  my_ip_address      = "174.141.204.193"
  ssh_private_key    = "~/.ssh/jph-cockroach-gcp"
  owner              = "jhaug"
}

provider "google" {
  alias      = "region-0"
  project    = local.project_name
  region     = "us-central1"
  credentials = file(local.credentials_file)
}

provider "google" {
  alias      = "region-1"
  project    = local.project_name
  region     = "us-west1"
  credentials = file(local.credentials_file)
}

provider "google" {
  alias      = "region-2"
  project    = local.project_name
  region     = "us-east1"
  credentials = file(local.credentials_file)
}


module "mymodule" {
  source = "../"   # points at multiregionGCP folder
  providers = {
    "google.region-0" = google.region-0
    "google.region-1" = google.region-1
    "google.region-2" = google.region-2
  }
  # ssh keys are not regional in GCP
  ssh_private_key      = local.ssh_private_key
  # ────────────────────────────────────────────────────────────────────────────
  # 1. MULTI-REGION DRIVER PARAMETERS
  # ────────────────────────────────────────────────────────────────────────────

  gcp_region_list      = ["us-central1", "us-west1", "us-east1"]

  # ────────────────────────────────────────────────────────────────────────────
  # 2. TAGS
  # ────────────────────────────────────────────────────────────────────────────

  project_name  = local.project_name
  environment   = "dev"
  owner         =  local.owner
  resource_tags = { Team = "Dev" }

  # ────────────────────────────────────────────────────────────────────────────
  # 3. VPC CIDRs
  # ────────────────────────────────────────────────────────────────────────────

  vpc_cidr_list = [
    "192.168.3.0/24",
    "192.168.4.0/24",
    "192.168.5.0/24"
  ]

  # ────────────────────────────────────────────────────────────────────────────
  # 4. USER IP (for Security Groups)
  # ────────────────────────────────────────────────────────────────────────────

  my_ip_address = local.my_ip_address

  # ────────────────────────────────────────────────────────────────────────────
  # 5. COCKROACHDB INSTANCE SPECIFICATIONS
  # ────────────────────────────────────────────────────────────────────────────

  crdb_nodes                  = 3
  crdb_instance_type          = "e2-standard-4"
  crdb_store_volume_type      = "pd-standard"
  crdb_store_volume_size      = 200
  crdb_version                = "25.2.2"
  crdb_arm_release            = "yes"
  crdb_enable_spot_instances  = "no"
  crdb_file_location          = "/mnt/data"

  # ────────────────────────────────────────────────────────────────────────────
  # 6. CLUSTER LOCATION DATA
  # ────────────────────────────────────────────────────────────────────────────

  install_system_location_data = "yes"
  allow_non_tls                = true

  # ────────────────────────────────────────────────────────────────────────────
  # 7. HA PROXY SETTINGS
  # ────────────────────────────────────────────────────────────────────────────

  include_ha_proxy        = "yes"
  haproxy_instance_type   = "e2-standard-4"

  # ────────────────────────────────────────────────────────────────────────────
  # 8. KAFKA SETTINGS
  # ────────────────────────────────────────────────────────────────────────────

  include_kafka          = "yes"
  kafka_instance_type    = "e2-standard-8"

  # ────────────────────────────────────────────────────────────────────────────
  # 9. APP NODE SETTINGS
  # ────────────────────────────────────────────────────────────────────────────

  include_app            = "yes"
  app_instance_type      = "e2-standard-8"
  create_dbadmin_user    = "yes"
  setup_migration        = "yes"
  dbadmin_user_name      = "jhaugland"
  dbadmin_user_password  = "jasonrocks"

  # ────────────────────────────────────────────────────────────────────────────
  # 10. ENTERPRISE LICENSE KEYS
  # ────────────────────────────────────────────────────────────────────────────

  full_path_license_directory = "~/.crdb/"

  # ────────────────────────────────────────────────────────────────────────────
  # 11. LOAD BALANCER
  # ────────────────────────────────────────────────────────────────────────────
  #  load balancer does not work on GCP yet
  include_load_balancer  = "no"
  run_ansible = true
  gcp_credentials_file   = local.credentials_file
}

