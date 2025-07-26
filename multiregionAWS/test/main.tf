###############################################################################
# test/main.tf
#
# Driver for multiregionAWS. Supplies exactly the list‐typed inputs that
# multiregionAWS/variables.tf now declares, including crdb_instance_key_name
# (a list of three key names) instead of a single crdb_instance_key_name.
###############################################################################

terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

module "mymodule" {
  source = "../"   # points at multiregionAWS folder

  # ────────────────────────────────────────────────────────────────────────────
  # 1. MULTI-REGION DRIVER PARAMETERS
  # ────────────────────────────────────────────────────────────────────────────

  aws_region_list      = ["us-east-1", "us-west-2", "us-east-2"]
  aws_instance_keys = [
    "jph-cockroach-us-east-1-kp01",
    "jph-cockroach-us-west-2-kp01",
    "jph-cockroach-us-east-2-kp01"
  ]
  ssh_private_key_list = [
    "~/.ssh/jph-cockroach-us-east-1-kp01.pem",
    "~/.ssh/jph-cockroach-us-west-2-kp01.pem",
    "~/.ssh/jph-cockroach-us-east-2-kp01.pem"
  ]

  # ────────────────────────────────────────────────────────────────────────────
  # 2. TAGS
  # ────────────────────────────────────────────────────────────────────────────

  project_name  = "terraform-test"
  environment   = "dev"
  owner         = "jhaug"
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

  my_ip_address = "174.141.204.193"

  # ────────────────────────────────────────────────────────────────────────────
  # 5. COCKROACHDB INSTANCE SPECIFICATIONS
  # ────────────────────────────────────────────────────────────────────────────

  crdb_nodes                  = 3
  crdb_instance_type          = "t4g.xlarge"
  crdb_store_volume_type      = "gp3"
  crdb_store_volume_size      = 8
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
  haproxy_instance_type   = "t3a.large"

  # ────────────────────────────────────────────────────────────────────────────
  # 8. KAFKA SETTINGS
  # ────────────────────────────────────────────────────────────────────────────

  include_kafka          = "yes"
  kafka_instance_type    = "t3a.xlarge"

  # ────────────────────────────────────────────────────────────────────────────
  # 9. APP NODE SETTINGS
  # ────────────────────────────────────────────────────────────────────────────

  include_app            = "yes"
  app_instance_type      = "t3a.xlarge"
  create_dbadmin_user    = "yes"
  setup_migration        = "yes"
  dbadmin_user_name      = "jhaugland"
  dbadmin_user_password  = "jasonrocks"

  # ────────────────────────────────────────────────────────────────────────────
  # 10. ENTERPRISE LICENSE KEYS
  # ────────────────────────────────────────────────────────────────────────────

  full_path_license_directory = "/Users/jasonhaugland/.crdb/"

  # ────────────────────────────────────────────────────────────────────────────
  # 11. LOAD BALANCER
  # ────────────────────────────────────────────────────────────────────────────

  include_load_balancer  = "yes"
  run_ansible = false

  # ────────────────────────────────────────────────────────────────────────────
  # 12. OPTIONAL TLS KEYS & CERTS
  # ────────────────────────────────────────────────────────────────────────────
  # (Uncomment below if your module’s variables.tf still expects TLS inputs)
  #
  # tls_private_key = file("path/to/ca.key")
  # tls_public_key  = file("path/to/ca.pub")
  # tls_cert        = file("path/to/ca.crt")
  # tls_user_cert   = file("path/to/client.crt")
  # tls_user_key    = file("path/to/client.key")
}

