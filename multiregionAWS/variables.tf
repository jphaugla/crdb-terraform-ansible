################################################################################
# variables.tf
#
# Defines exactly the inputs required by each “crdb-region-<N>” block in
# regions.tf. No extra or mis-named variables.
################################################################################

# ─────────────────────────────────────────────────────────────────────────────
# 1. MULTI-REGION DRIVER PARAMETERS
# ─────────────────────────────────────────────────────────────────────────────

variable "aws_region_list" {
  description = "List of three AWS regions to deploy CockroachDB (e.g. [\"us-east-1\",\"us-west-2\",\"us-east-2\"])."
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "us-east-2"]
}

variable "aws_instance_keys" {
  description = "List of three EC2 Key Pair names—one per region, in the same order as aws_region_list."
  type        = list(string)
  default     = [
    "nollen-cockroach-us-east-1-kp01",
    "nollen-cockroach-us-west-2-kp01",
    "nollen-cockroach-us-east-2-kp01"
  ]
}

variable "ssh_private_key_list" {
  description = "List of three local paths to the private key files—one per region, matching aws_instance_keys."
  type        = list(string)
  default     = [
    "~/.ssh/nollen-cockroach-us-east-1-kp01.pem",
    "~/.ssh/nollen-cockroach-us-west-2-kp01.pem",
    "~/.ssh/nollen-cockroach-us-east-2-kp01.pem"
  ]
}

# ─────────────────────────────────────────────────────────────────────────────
# 2. TAGS (APPLIED TO ALL REGIONS)
# ─────────────────────────────────────────────────────────────────────────────

variable "project_name" {
  description = "Name of the project (applied as a tag to every resource)."
  type        = string
  default     = "terraform-test"
}

variable "environment" {
  description = "Name of the environment (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner of the infrastructure (applied as a tag)."
  type        = string
  default     = ""
}

variable "resource_tags" {
  description = "Additional tags (map of string→string) to apply to all resources."
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────────────────────────────────────
# 3. VPC CIDRs
# ─────────────────────────────────────────────────────────────────────────────

variable "vpc_cidr_list" {
  description = "List of three VPC CIDR blocks—one per region."
  type        = list(string)
  default     = ["192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24"]
}

variable "vpc_cidr" {
  description = "Single VPC CIDR block (not used in multi-region driver)."
  type        = string
  default     = "192.168.4.0/24"
}

# ─────────────────────────────────────────────────────────────────────────────
# 4. USER’S PUBLIC IP (for SG rules)
# ─────────────────────────────────────────────────────────────────────────────

variable "my_ip_address" {
  description = <<EOF
User IP/CIDR to authorize in each Security Group for:
• 22 (SSH)
• 26257 (CockroachDB)
• 8080 (Observability)
• 3389 (RDP, if needed)
EOF
  type        = string
  default     = "0.0.0.0/0"
}

# ─────────────────────────────────────────────────────────────────────────────
# 5. COCKROACHDB INSTANCE SPECIFICATIONS
# ─────────────────────────────────────────────────────────────────────────────

variable "crdb_nodes" {
  description = "Number of CockroachDB nodes per region (must be a multiple of 3)."
  type        = number
  default     = 3

  validation {
    condition     = var.crdb_nodes % 3 == 0
    error_message = "The variable 'crdb_nodes' must be a multiple of 3."
  }
}

variable "crdb_instance_type" {
  description = "EC2 instance type for CockroachDB nodes."
  type        = string
  default     = "m6i.large"

  validation {
    condition = contains([
      "t2.micro","t3a.small","t3.small","t3a.micro","t3a.medium","t3.medium","t3a.large",
      "c5a.large","t3.large","t4g.xlarge","t4g.large","c5.large","c6i.large","c5ad.large","m5a.large","m6a.large",
      "t2.large","c5d.large","m5.large","m6i.large","c4.large","m4.large","m5ad.large",
      "c5n.large","m5d.large","r5a.large","m5n.large","r5.large","r6i.large","c1.medium",
      "r5ad.large","m3.large","r4.large","m5dn.large","r5d.large","r5b.large","r5n.large",
      "t3a.xlarge","c5a.xlarge","i3.large","m5zn.large","r3.large","t3.xlarge","r5dn.large",
      "c5.xlarge","c6i.xlarge","c5ad.xlarge","c5d.2xlarge","c5d.4xlarge","c5d.9xlarge",
      "m5.xlarge","m5.2xlarge","m5.4xlarge","m5.8xlarge","m5a.xlarge","m5a.2xlarge",
      "m5a.4xlarge","m5a.8xlarge","m6a.xlarge","m6a.2xlarge","m6a.4xlarge","m6a.8xlarge",
      "m6i.xlarge","m6i.2xlarge","m6i.4xlarge","m6i.8xlarge"
    ], var.crdb_instance_type)
    error_message = "Invalid 'crdb_instance_type'; see allowed list in variables.tf."
  }
}

variable "crdb_store_volume_type" {
  description = "EBS volume type for CockroachDB data (gp2 or gp3)."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3"], var.crdb_store_volume_type)
    error_message = "'crdb_store_volume_type' must be 'gp2' or 'gp3'."
  }
}

variable "crdb_store_volume_size" {
  description = "EBS volume size (GiB) for CockroachDB data."
  type        = number
  default     = 8
}

variable "crdb_version" {
  description = "CockroachDB version to install."
  type        = string
  default     = "25.2.2"

  validation {
    condition = contains([
      "25.2.1","25.2.2",
      "25.2.0","25.1.6","25.1.5","25.1.4","25.1.3","25.1.2","25.1.1",
      "24.2.8","24.2.6","24.2.5","24.2.4","24.2.3","24.2.2","24.2.1",
      "23.2.19","23.2.18","23.2.17","23.2.1","23.1.14","23.1.13"
    ], var.crdb_version)
    error_message = "Select a valid 'crdb_version'; see list in variables.tf."
  }
}

variable "crdb_arm_release" {
  description = "Use ARM-optimized CockroachDB build? (‘yes’/‘no’)."
  type        = string
  default     = "yes"

  validation {
    condition     = contains(["yes", "no"], var.crdb_arm_release)
    error_message = "'crdb_arm_release' must be 'yes' or 'no'."
  }
}

variable "crdb_enable_spot_instances" {
  description = "Allow Spot instances for CockroachDB? (‘yes’/‘no’)."
  type        = string
  default     = "no"

  validation {
    condition     = contains(["yes", "no"], var.crdb_enable_spot_instances)
    error_message = "'crdb_enable_spot_instances' must be 'yes' or 'no'."
  }
}

variable "crdb_file_location" {
  description = "Filesystem path on each CockroachDB node to store data (e.g. '/mnt/data')."
  type        = string
  default     = "/mnt/data"
}

# ─────────────────────────────────────────────────────────────────────────────
# 6. CLUSTER LOCATION DATA
# ─────────────────────────────────────────────────────────────────────────────

variable "install_system_location_data" {
  description = "Install system location data? (‘yes’/‘no’)."
  type        = string
  default     = "yes"

  validation {
    condition     = contains(["yes", "no"], var.install_system_location_data)
    error_message = "'install_system_location_data' must be 'yes' or 'no'."
  }
}

variable "allow_non_tls" {
  description = "Allow non-TLS client connections? (true/false)."
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────────────────────────────────────
# 7. HA PROXY SETTINGS
# ─────────────────────────────────────────────────────────────────────────────

variable "include_ha_proxy" {
  description = "Include HAProxy instance? (‘yes’/‘no’)."
  type        = string
  default     = "yes"

  validation {
    condition     = contains(["yes", "no"], var.include_ha_proxy)
    error_message = "'include_ha_proxy' must be 'yes' or 'no'."
  }
}

variable "haproxy_instance_type" {
  description = "EC2 instance type for HAProxy (if included)."
  type        = string
  default     = "t3a.large"
}

# ─────────────────────────────────────────────────────────────────────────────
# 8. KAFKA SETTINGS
# ─────────────────────────────────────────────────────────────────────────────

variable "include_kafka" {
  description = "Include Kafka instance? (‘yes’/‘no’)."
  type        = string
  default     = "no"

  validation {
    condition     = contains(["yes", "no"], var.include_kafka)
    error_message = "'include_kafka' must be 'yes' or 'no'."
  }
}

variable "kafka_instance_type" {
  description = "EC2 instance type for Kafka (if included)."
  type        = string
  default     = "t3a.xlarge"
}

# ─────────────────────────────────────────────────────────────────────────────
# 9. APP NODE SETTINGS
# ─────────────────────────────────────────────────────────────────────────────

variable "include_app" {
  description = "Include dedicated App node? (‘yes’/‘no’)."
  type        = string
  default     = "yes"

  validation {
    condition     = contains(["yes", "no"], var.include_app)
    error_message = "'include_app' must be 'yes' or 'no'."
  }
}

variable "app_instance_type" {
  description = "EC2 instance type for the App node (if included)."
  type        = string
  default     = "t3a.xlarge"
}

variable "create_dbadmin_user" {
  description = "Create DB-admin user? (‘yes’/‘no’)."
  type        = string
  default     = "yes"

  validation {
    condition     = contains(["yes", "no"], var.create_dbadmin_user)
    error_message = "'create_dbadmin_user' must be 'yes' or 'no'."
  }
}

variable "setup_migration" {
  description = "Run database migrations? (‘yes’/‘no’)."
  type        = string
  default     = "yes"

  validation {
    condition     = contains(["yes", "no"], var.setup_migration)
    error_message = "'setup_migration' must be 'yes' or 'no'."
  }
}

variable "dbadmin_user_name" {
  description = "Username for DB-admin user (if created)."
  type        = string
  default     = "jhaugland"
}

variable "dbadmin_user_password" {
  description = "Password for DB-admin user (if created)."
  type        = string
  default     = "jasonrocks"
}

# ─────────────────────────────────────────────────────────────────────────────
# 10. ENTERPRISE LICENSE KEYS
# ─────────────────────────────────────────────────────────────────────────────

variable "full_path_license_directory" {
  description = <<EOF
Directory containing two files:
  • enterprise_licence  
  • cluster_organization

Both should reside under this folder.
EOF
  type    = string
  default = "/Users/jasonhaugland/.crdb/"
}

# ─────────────────────────────────────────────────────────────────────────────
# 11. LOAD BALANCER
# ─────────────────────────────────────────────────────────────────────────────

variable "include_load_balancer" {
  description = "Create a Network Load Balancer? (‘yes’/‘no’)."
  type        = string
  default     = "yes"

  validation {
    condition     = contains(["yes", "no"], var.include_load_balancer)
    error_message = "'include_load_balancer' must be 'yes' or 'no'."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# 12. TLS KEYS & CERTS (OPTIONAL)
# ─────────────────────────────────────────────────────────────────────────────

variable "tls_private_key" {
  description = "TLS Private Key PEM (override auto-generated if desired)."
  type        = string
  default     = ""
}

variable "tls_public_key" {
  description = "TLS Public Key PEM (override auto-generated if desired)."
  type        = string
  default     = ""
}

variable "tls_cert" {
  description = "TLS CA certificate PEM (override auto-generated if desired)."
  type        = string
  default     = ""
}

variable "tls_user_cert" {
  description = "TLS client certificate PEM (override auto-generated if desired)."
  type        = string
  default     = ""
}

variable "tls_user_key" {
  description = "TLS client private key PEM (override auto-generated if desired)."
  type        = string
  default     = ""
}


variable "run_ansible" {
  description = "run ansible code in each region.  Turn off when just making a terrform only change"
  type        = bool
  default     = true
}
