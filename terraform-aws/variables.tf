# ----------------------------------------
# Cluster Enterprise License Keys
# ----------------------------------------
  variable "install_enterprise_keys" {
    description = "Setting this to 'yes' will attempt to install enterprise license keys into the cluster.  The environment variables (TF_VAR_cluster_organization and TF_VAR_enterprise_license)"
    type = string
    default = "no"
    validation {
      condition = contains(["yes", "no"], var.install_enterprise_keys)
      error_message = "Valid value for variable 'install_enterprise_keys' is : 'yes' or 'no'"        
    }
  }

  # Be sure to do the following in your environment if you plan on installing the license keys
  #   export TF_VAR_cluster_organization='your cluster organization'
  #   export TF_VAR_enterprise_license='your enterprise license'
  variable "cluster_organization" { 
    type = string  
    default = "" 
  }
  variable "enterprise_license"   { 
    type = string  
    default = "" 
  }

# ----------------------------------------
# Cluster Location Data - For console map
# ----------------------------------------
  variable "install_system_location_data" {
    description = "Setting this to 'yes' will attempt to install data in the system.location table.  The data will be used by the console to display cluster node locations)"
    type = string
    default = "yes"
    validation {
      condition = contains(["yes", "no"], var.install_system_location_data)
      error_message = "Valid value for variable 'install_system_location_data' is : 'yes' or 'no'"        
    }
  }

# ----------------------------------------
# Create EC2 Instances
# ----------------------------------------
  variable "create_ec2_instances" {
    description = "create the ec2 instances (yes/no)?  If set to 'no', then only the VPC, subnets, routes tables, routes, peering, etc are created"
    type = string
    default = "yes"
    validation {
      condition = contains(["yes", "no"], var.create_ec2_instances)
      error_message = "Valid value for variable 'create_ec2_instances' is : 'yes' or 'no'"        
    }
  }

# ----------------------------------------
# Regions
# ----------------------------------------
    # Needed for the multi-region-demo
    variable "virtual_network_location" {
      description = "AWS region"
      type        = string
    }

    # This is not used except for the mult-region-demo function being added to the bashrc
    variable "aws_region_list" {
      description = "list of the AWS regions for the crdb cluster"
      default = ["not", "used", "in-single"]
      type = list
    }

# ----------------------------------------
# TAGS
# ----------------------------------------
    # Required tags
    variable "project_name" {
      description = "Name of the project."
      type        = string
      default     = "terraform-test"
    }

    variable "owner" {
      description = "Owner of the infrastructure"
      type        = string
      default     = ""
    }

    # Optional tags
    variable "resource_tags" {
      description = "Tags to set for all resources"
      type        = map(string)
      default     = {}
    }


# ----------------------------------------
# CIDR
# ----------------------------------------
    variable "vpc_cidr" {
      description = "CIDR block for the VPC"
      type        = string
      default     = "192.168.4.0/24"
    }

# ----------------------------------------
# My IP Address
# This is used in the creation of the security group 
# and will allow access to the ec2-instances on ports
# 22 (ssh), 26257 (database), 8080 (for observability)
# and 3389 (rdp)
# ----------------------------------------
    variable "my_ip_address" {
      description = "User IP address for access to the ec2 instances."
      type        = string
      default     = "0.0.0.0"
    }

    variable "ssh_private_key" {
      description = "The full path of the private key"
      type        = string
    }

# ----------------------------------------
# CRDB Instance Specifications
# ----------------------------------------
    variable "join_string" {
      description = "The CRDB join string to use at start-up.  Do not supply a value"
      type        = string
      default     = ""
    }

    variable "prometheus_string" {
      description = "The prometheus string to use at start-up.  Do not supply a value"
      type        = string
      default     = ""
    }

    variable "prometheus_app_string" {
      description = "The  prometheus string to use at start-up.  Do not supply a value"
      type        = string
      default     = ""
    }

    variable "crdb_nodes" {
      description = "Number of crdb nodes.  This should be a multiple of 3.  Each node is an AWS Instance"
      type        = number
      default     = 3
      validation {
        condition = var.crdb_nodes%3 == 0
        error_message = "The variable 'crdb_nodes' must be a multiple of 3"
      }
    }

    variable "crdb_instance_type" {
      description = "The AWS instance type for the crdb instances."
      type        = string
      default     = "m7g.xlarge"
    }

    variable "crdb_file_location" {
      description = "The mount point for large files.  Subdirectory of adminuser will be added as well"
      type        = string
      default     = "/mnt/data"
    }

    variable "allow_non_tls" {
      description = "start the nodes with the accept-sql-without-tls flag which is insecure"
      type        = bool
      default     = false
    }

    variable "full_path_license_directory" {
       description = "full path to the license directory, needs two files cluster_organization and enterprise_lincense in the directory"
    }

    variable "crdb_arm_release" {
      description = "Do you want to use the ARM version of CRDB?  There are implications on the instances available for the installation.  You must choose the correct instance type or this will fail."
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.crdb_arm_release)
        error_message = "Valid value for variable 'arm' is : 'yes' or 'no'"        
      } 
    }

    variable "crdb_enable_spot_instances" {
      description = "Do you want to use SPOT instances?  There are implications on the instances available for the installation.  You must choose the correct instance type or this will fail."
      type        = string
      default     = "no"
      validation {
        condition = contains(["yes", "no"], var.crdb_enable_spot_instances)
        error_message = "Valid value for variable 'spot instances' is : 'yes' or 'no'"        
      } 
    }

    variable "crdb_root_volume_type" {
      description = "EBS Root Volume Type"
      type        = string
      default     = "gp2"
      validation {
        condition = contains(["gp2", "gp3"], var.crdb_root_volume_type)
        error_message = "Valid values for variable crdb_root_volume_type is one of the following: 'gp2', 'gp3'"
      }
    }

    variable "crdb_root_volume_size" {
      description = "EBS Root Volume Size"
      type        = number
      default     = 8
    }

    variable "crdb_store_volume_type" {
      description = "EBS Root Volume Type"
      type        = string
      default     = "gp2"
      validation {
        condition = contains(["gp2", "gp3"], var.crdb_store_volume_type)
        error_message = "Valid values for variable crdb_root_volume_type is one of the following: 'gp2', 'gp3'"
      }
    }

    variable "crdb_store_volume_size" {
      description = "EBS Root Volume Size"
      type        = number
      default     = 8
    }

    variable "crdb_instance_key_name" {
      description = "The key name to use for the crdb instance -- this key must already exist"
      type        = string
      nullable    = false
    }

    variable "crdb_version" {
      description = "CockroachDB Version"
      type        = string
      default     = "25.2.0"
    }

    variable "run_init" {
      description = "'yes' or 'no' to include an HAProxy Instance"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.run_init)
        error_message = "Valid value for variable 'include_ha_proxy' is : 'yes' or 'no'"        
      }
    }

    variable "create_dbadmin_user" {
      description = "'yes' or 'no' to create an admin user in the database.  This might only makes sense when adding an app instance since the certs will be created and configured automatically for connection to the database."
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.create_dbadmin_user)
        error_message = "Valid value for variable 'include_ha_proxy' is : 'yes' or 'no'"        
      }      
    }

    variable "dbadmin_user_name"{
      description = "An admin with this username will be created if 'create_dbadmin_user=yes'"
      type        = string
      default     = ""
    }

    variable "dbadmin_user_password"{
      description = "password for the admin user"
      type        = string
      default     = ""
    }

# ----------------------------------------
# HA Proxy Instance Specifications
# ----------------------------------------
    variable "include_ha_proxy" {
      description = "'yes' or 'no' to include an HAProxy Instance"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.include_ha_proxy)
        error_message = "Valid value for variable 'include_ha_proxy' is : 'yes' or 'no'"        
      }
    }

    variable "haproxy_instance_type" {
      description = "HA Proxy Instance Type"
      type        = string
      default     = "t3a.small"
    }

# ----------------------------------------
# Kafka Instance Specifications
# ----------------------------------------
    variable "include_kafka" {
      description = "'yes' or 'no' to include an kafka Instance"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.include_kafka)
        error_message = "Valid value for variable 'include_kafka' is : 'yes' or 'no'"        
      }
    }

    variable "kafka_instance_type" {
      description = "Kafka Instance Type"
      type        = string
      default     = "t3a.small"
    }

# ----------------------------------------
# ----------------------------------------
# APP Instance Specifications
# ----------------------------------------
    variable "include_app" {
      description = "'yes' or 'no' to include an HAProxy Instance"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.include_app)
        error_message = "Valid value for variable 'include_app' is : 'yes' or 'no'"        
      }
    }

    variable "app_instance_type" {
      description = "App Instance Type"
      type        = string
      default     = "t3a.micro"
    }

    variable "setup_migration" {
      description = "'yes' or 'no' to setup migration"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.setup_migration)
        error_message = "Valid value for variable 'setup_migration' is : 'yes' or 'no'"
      }
    }

# ----------------------------------------
# Demo
# ----------------------------------------
    variable "include_demo" {
      description = "'yes' or 'no' to include an HAProxy Instance"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.include_demo)
        error_message = "Valid value for variable 'include_demo' is : 'yes' or 'no'"        
      }
    }

# ----------------------------------------
# TLS Vars -- Leave blank to have then generated
# ----------------------------------------
    variable "tls_private_key" {
      description = "tls_private_key.crdb_ca_keys.private_key_pem -> ca.key / TLS Private Key PEM"
      type        = string
      default     = ""
    }

    variable "tls_public_key" {
      description = "tls_private_key.crdb_ca_keys.public_key_pem -> ca.pub / TLS Public Key PEM"
      type        = string
      default     = ""
    }

    variable "tls_cert" {
      description = "tls_self_signed_cert.crdb_ca_cert.cert_pem -> ca.crt / TLS Cert PEM"
      type        = string
      default     = ""
    }

    variable "tls_user_cert" {
      description = "tls_locally_signed_cert.user_cert.cert_pem -> client.name.crt"
      type        = string
      default     = ""
    }

    variable "tls_user_key" {
      description = "tls_private_key.client_keys.private_key_pem -> client.name.key"
      type        = string
      default     = ""
    }

    variable "instances_inventory_file" {
        description = "File name to send inventory details for ansible later. this is relative to the calling main.tf file"
        type        = string
        default = "../inventory"
    }

    variable "playbook_working_directory" {
        description = "Path for the working directory"
        type        = string
        default = "../../ansible"
    }

    variable "playbook_instances_inventory_file" {
        description = "Path for the playbook command to use for the instances inventory file"
        type        = string
        default = "../terraform-aws/inventory"
    }

    variable "instances_inventory_directory" {
        description = "Path for the inventory directory, this is relative to playbook_working_directory"
        type        = string
        default = "../temp/"
    }

    variable "inventory_template_file" {
        description = "File name and Path to for inventory template file."
        type        = string
        default = "../terraform-aws/templates/inventory.tpl"
    }

# ----------------------------------------
# Network Load Balancer
# ----------------------------------------
    variable "include_load_balancer" {
      description = "'yes' or 'no' to include a load balancer"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.include_load_balancer)
        error_message = "Valid value for variable 'include_kafka' is : 'yes' or 'no'"
      }
    }

    variable "ansible_verbosity_switch" {
        description = "Set the about of verbosity to pass through to the ansible playbook command. No additional verbosity by default. Example: -v or -vv or -vvv."
        default = ""
    }

    variable "run_ansible" {
      type        = bool
      description = "Whether to run the Ansible playbooks in each region"
      default     = true
    }

    variable "environment" {
      description = "Deployment environment (e.g. dev, staging, prod)"
      type        = string
      default     = "dev"
    }
