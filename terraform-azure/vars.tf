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

# ----------------------------------------
# Globals
# ----------------------------------------
    variable "resource_name" {
      description = "resource names will usually be the concatenation of var.owner-var.resource_name-resourceType and also a count.index if there are mulitple resources"
      type        = string
      default     = "demo"
    }
    variable "owner" {
      description = "Owner of the infrastructure"
      type        = string
    }
    variable "allow_non_tls" {
      description = "start the nodes with the accept-sql-without-tls flag which is insecure"
      type        = bool
      default     = false
    }
    # ----------------------------------------
    # Create EC2 Instances - for testing purposes
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
# Multi-Region
# ----------------------------------------    
    # Please leave these variables as is.  When using this as a module in the multi-region setup, these will be passed in.  For single region, leave as is.  Total hack.
    variable "multi_region" {
      type        = bool
      default     = false
    }
    variable "multi_region_resource_group_name" {
      description = "This will be the resource_group_location"
      type        = string
      default     = ""
    }

# ----------------------------------------
# Existing Key Info
# ----------------------------------------
    variable "ssh_key_name" {
      description = "The name of an existing ssh key "
      type    = string      
    }
    variable "ssh_key_resource_group" {
      description = "The name of the resource group containing the existing SSH Key"
      type        = string
    }
    variable "ssh_private_key" {
      description = "The full path of the private key"
      type        = string
    }

# ----------------------------------------
# Resource Group
# ----------------------------------------
    variable "resource_group_location" {
      # you must leave the default as an empty string.  for single region, pass in the value in terraform.tfvars.  for multi-region, pass in the value.
      type    = string
      default = "westeurope"
    }

# ----------------------------------------
# TAGS
# ----------------------------------------
    # owner will be applied to all resources that accept tags along with any other optional tags specified here. 
    # Optional tags
    variable "resource_tags" {
      description = "Tags to set for all resources"
      type        = map(string)
      default     = {}
    }

# ----------------------------------------
# Regions
# ----------------------------------------
    # This is not used except for the mult-region-demo function being added to the bashrc -- please just go with it.  Total hack.
    variable "virtual_network_locations" {
      description = "list of the Azure regions for the crdb cluster"
      type = list
      default = ["westus2", "centralus", "eastus2"]
    }

# ----------------------------------------
# Network
# ----------------------------------------
    variable "virtual_network_cidr" {
      description = "CIDR block for the VPC"
      type        = string
      default     = "192.168.4.0/24"
    }
    variable "virtual_network_location" {
      type    = string
      default = "westeurope"
    }

# ----------------------------------------
# azure login user name for all the azure compute engine VMs
# ----------------------------------------
    variable "login_username" {
      description = "the login user for the azure compute engine VMs, normally is adminuser"
      type        = string
      default     = "adminuser"
    }
# ----------------------------------------
# CRDB Instance Specifications
# ----------------------------------------
    variable "crdb_vm_size" {
      description = "The Azure instance type for the crdb instances."
      type        = string
      default     = "m6i.large"
    }
    variable "crdb_file_location" {
      description = "The mount point for large files.  Subdirectory of adminuser will be added as well"
      type        = string
      default     = "/mnt/data"
    }
    variable "crdb_nodes" {
      description = "Number of crdb nodes.  This should be a multiple of 3.  Each node is an Azure Instance"
      type        = number
      default     = 3
      validation {
        condition = var.crdb_nodes%3 == 0
        error_message = "The variable 'crdb_nodes' must be a multiple of 3"
      }
    }
    variable "crdb_disk_size" {
      description = "Size of the disk attached to the vm"
      type        = number
      default     = 64
      validation {
        condition = contains([64, 128, 256, 512, 1024, 2048, 3072, 4096], var.crdb_disk_size)
        error_message = "CRDB Node disk size (in GB) must be 64, 128, 256, 512, 1024, 2048, 3072 or 4096"
      }
    }
    variable "crdb_store_disk_size" {
      description = "Size of the data disk attached to the vm"
      type        = number
      default     = 64
      validation {
        condition = contains([64, 128, 256, 512, 1024, 2048, 3072, 4096], var.crdb_store_disk_size)
        error_message = "CRDB Node disk size (in GB) must be 64, 128, 256, 512, 1024, 2048, 3072 or 4096"
      }
    }
# ----------------------------------------
# CRDB Admin User  - database admin user
# ----------------------------------------
    variable "create_dbadmin_user" {
      description = "'yes' or 'no' to create an admin user in the database.  This might only makes sense when adding an app instance since the certs will be created and configured automatically for connection to the database."
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.create_dbadmin_user)
        error_message = "Valid value for variable 'create_dbadmin_user' is : 'yes' or 'no'"        
      }      
    }
    variable "dbadmin_user_name"{
      description = "An database admin with this username will be created if 'create_dbadmin_user=yes'"
      type        = string
      default     = ""
    }
    variable "dbadmin_user_password"{
      description = "password for the database admin user"
      type        = string
      default     = ""
    }

# ----------------------------------------
# CRDB Specifications
# ----------------------------------------
    variable "join_string" {
      description = "The CRDB join string to use at start-up.  Do not supply a value"
      type        = string
      default     = ""
    }
    variable "prometheus_string" {
      description = "The CRDB prometheus string to use at start-up.  Do not supply a value"
      type        = string
      default     = ""
    }
    variable "prometheus_app_string" {
      description = "The  prometheus string to use at start-up.  Do not supply a value"
      type        = string
      default     = ""
    }
    variable "crdb_version" {
      description = "CockroachDB Version"
      type        = string
      default     = "22.2.10"
    }
    variable "run_init" {
      description = "'yes' or 'no' to run init on the database.  In a multi-region configuration, only run the init in one of the regions."
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.run_init)
        error_message = "Valid value for variable 'run_init' is : 'yes' or 'no'"        
      }
    }

# ----------------------------------------
# Cluster Enterprise License Keys
# ----------------------------------------
  variable "install_enterprise_keys" {
    description = "Setting this to 'yes' will attempt to install enterprise license keys into the cluster.  The environment variables (TF_VAR_cluster_organization and TF_VAR_enterprise_license)"
    type    = bool
    default = false
  }

  # Be sure to do the following in your environment if you plan on installing the license keys
  #   export TF_VAR_cluster_organization='your cluster organization'
  #   export TF_VAR_enterprise_license='your enterprise license'
#   variable "cluster_organization" { 
#     type = string  
#     default = "" 
#   }
#   variable "enterprise_license"   { 
#     type = string  
#     default = "" 
#  }
# 
#   resource "local_file" "write_license" {
#    filename = "../provisioners/temp/${var.virtual_network_location}/enterprise_license"
#    content = var.enterprise_license
#   }
#   resource "local_file" "write_cluster_org" {
#    filename = "../provisioners/temp/${var.virtual_network_location}/cluster_organization"
#    content = var.cluster_organization
#   }
# ----------------------------------------
# Cluster Location Data - For console map
# ----------------------------------------
  variable "install_system_location_data" {
    description = "Setting this to 'yes' will attempt to install data in the system.location table.  The data will be used by the console to display cluster node locations)"
    type = string
    default = "no"
    validation {
      condition = contains(["yes", "no"], var.install_system_location_data)
      error_message = "Valid value for variable 'install_system_location_data' is : 'yes' or 'no'"        
    }
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

    variable "haproxy_vm_size" {
      description = "The Azure instance type for the crdb instances HA Proxy Instance"
      type        = string
      default     = "t3a.small"
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


# ----------------------------------------
# Kafka Instance Specifications
# ----------------------------------------
    variable "include_kafka" {
      description = "'yes' or 'no' to include a Kafka instance"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.include_kafka)
        error_message = "Valid value for variable 'include_kafka' is : 'yes' or 'no'"        
      }
    }

    variable "kafka_vm_size" {
      description = "The Azure instance type for the crdb instances Kafka"
      type        = string
      default     = "t3a.small"
    }

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

    variable "start_replicator" {
      description = "'yes' or 'no' to start replicator application"
      type        = string
      default     = "yes"
      validation {
        condition = contains(["yes", "no"], var.start_replicator)
        error_message = "Valid value for variable 'start_replicator' is : 'yes' or 'no'"        
      }
    }

    variable "app_nodes" {
      description = "Number of app nodes.    Each node is an Azure Instance"
      type        = number
      default     = 1
    }

    variable "app_vm_size" {
      description = "The Azure instance type for the crdb instances app Instance"
      type        = string
      default     = "t3a.micro"
    }

    variable "app_disk_size" {
      description = "Size of the disk attached to the vm"
      type        = number
      default     = 64
      validation {
        condition = contains([64, 128, 256, 512], var.app_disk_size)
        error_message = "CRDB Node disk size (in GB) must be 64, 128, 256 or 512"
      }
    }

    # Note that app_resize_homelv is dangerous.  Only use this option if you are use the redhat source image and only if you are sure
    # that sda2 contains the lv "rootvg-homelv".   This procedure will add any unused space to homelv.
    variable "app_resize_homelv" {
      description = "When creating a larger disk than exists in the image you'll need to repartition the disk to use the remaining space."
      type        = string
      default     = "no"
      validation {
        condition = contains(["yes", "no"], var.app_resize_homelv)
        error_message = "Valid value for variable 'crdb_resize_homelv' is : 'yes' or 'no'"        
      }  
    }

# ----------------------------------------
# Demo
# ----------------------------------------
    variable "include_demo" {
      description = "'yes' or 'no' to include an HAProxy Instance"
      type        = string
      default     = "no"
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

    variable "tls_self_signed_cert" {
      description = "tls_self_signed_cert.crdb_ca_cert.cert_pem -> ca.crt / TLS Cert PEM  /  Duplicate of tls_cert for better naming"
      type        = string
      default     = ""
    }

    variable "tls_user_cert" {
      description = "tls_locally_signed_cert.user_cert.cert_pem -> client.name.crt"
      type        = string
      default     = ""
    }

    variable "tls_locally_signed_cert" {
      description = "tls_locally_signed_cert.user_cert.cert_pem -> client.name.crt / Duplicate of tls_user_cert for better naming"
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
        default = "../terraform-azure/inventory"
    }

    variable "instances_inventory_directory" {
        description = "Path for the inventory directory, this is relative to playbook_working_directory"
        type        = string
        default = "../temp/"
    }

    variable "inventory_template_file" {
        description = "File name and Path to for inventory template file."
        type        = string
        default = "../terraform-azure/templates/inventory.tpl"
    }

    variable "ansible_verbosity_switch" {
        description = "Set the about of verbosity to pass through to the ansible playbook command. No additional verbosity by default. Example: -v or -vv or -vvv."
        default = ""
    }

# NOTE that you can't change this without changing parts of the provisioning scripts.
variable "test-publisher" {
  description = "The owner of the image"
  default     = "RedHat"
}

variable "test-offer" {
  description = "The type of the image"
  default     = "RHEL"
}

variable "test-sku" {
  description = "The SKU of the image"
  default     = "8-lvm-gen2"
}

variable "test-version" {
  description = "The version of the image"
  default     = "latest"
}

variable "full_path_license_directory" {
  description = "full path to the license directory, needs two files cluster_organization and enterprise_lincense in the directory"
}
# ----------------------------------------
# The following was created to account for NetSkope Tunneling
# ----------------------------------------
variable netskope_ips {
   description = "A list of IP CIDR ranges to allow as clients.  The IPs listed below are Netskope IP Ranges"
   default     = ["8.36.116.0/24" ,"8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
   type        = list(string)
}
