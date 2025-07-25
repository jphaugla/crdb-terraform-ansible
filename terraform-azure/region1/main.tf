provider "azurerm" {
 features {}
}

module "azure" {
  source           = "../"
  
# ----------------------------------------
# Globals
# ----------------------------------------
   owner                      = "jhaug"
   resource_name              = "central" # This is NOT the resource group name, but is used to form the resource group name unless it is passed in as multi-region-resource-group-name
   multi_region               = false
   
# ----------------------------------------
# My IP Address - security group config
# ----------------------------------------
   my_ip_address              = "174.141.204.193"
   
# ----------------------------------------
# Allow non-TLS connections
# ----------------------------------------
  allow_non_tls              = true

# ----------------------------------------
# Resource Group
# ----------------------------------------
   resource_group_location    = "centralus"
   
# ----------------------------------------
# Existing Key Info
# ----------------------------------------
   ssh_key_name           = "jhaugland-centralus"
   ssh_key_resource_group = "jhaugland-key-central-us"
   ssh_private_key              = "~/.ssh/jhaugland-centralus.pem"
   
# ----------------------------------------
# Network
# ----------------------------------------
   virtual_network_cidr       = "192.168.3.0/24"
   virtual_network_location   = "centralus"

#  file location for larger files not to be placed in the user home directory
#  will be created as root but owned by the adminuser on app-node and crdb-nodes 
#  will hold application log files, cockraoch_data, and other large files.  Subdirectories
#  will be used from this location.  this crdb_file_location will be the mount point.  the first subdirectory will be the adminuser
   crdb_file_location         = "/mnt/data"
   
# ----------------------------------------
# CRDB Instance Specifications
# ----------------------------------------
   crdb_vm_size               = "Standard_D4s_v5"
   crdb_disk_size             = 128
   crdb_nodes                 = 3
   
# ----------------------------------------
# CRDB Admin User - Cert Connection
# ----------------------------------------
   create_dbadmin_user        = "yes"
   dbadmin_user_name          = "jhaugland"
   dbadmin_user_password      = "jasonrocks"
   
# ----------------------------------------
# CRDB Specifications
# ----------------------------------------
   crdb_version               = "25.2.2"
   
# ----------------------------------------
# Cluster Enterprise License Keys
# ----------------------------------------
# Be sure to do the following in your environment if you plan on installing the license keys
# must add the enterprise licence and the cluster organization to specified subdirectory 
#  ${full_path_license_directory}/enterprise_licence
#  ${full_path_license_directory}/cluster_organization
   install_enterprise_keys   = "false"
   full_path_license_directory = "/Users/jasonhaugland/.crdb/"
   
# ----------------------------------------
# HA Proxy Instance Specifications
# ----------------------------------------
   haproxy_vm_size            = "Standard_D4s_v5"
# ----------------------------------------
# Create Network load balancer
# ----------------------------------------
   include_load_balancer           = "yes"
   
# ----------------------------------------
# APP Instance Specifications
# ----------------------------------------
   include_app                = "yes"
#  this will install postgres with employee database and start replicator
   start_replicator           = "no"
   setup_migration           = "yes"
   app_nodes                  = 1
   app_vm_size                = "Standard_D4s_v5"
   app_disk_size              = 64
   
# ----------------------------------------
# Kafka Instance Specifications
# ----------------------------------------
   include_kafka           = "yes"
   kafka_vm_size             = "Standard_D4s_v5"
   
# ----------------------------------------
# Cluster Location Data - For console map
# ----------------------------------------
   install_system_location_data = "yes"
   
# ----------------------------------------
# Ansible variables
# ----------------------------------------
   ansible_verbosity_switch = ""
   
# ----------------------------------------
# Image parameters for Kafka and app node
# ----------------------------------------
   test-publisher = "Canonical"
   test-offer     = "0001-com-ubuntu-server-jammy"
   test-sku       = "22_04-lts-gen2"
   test-version   = "latest"
   run_ansible    = true
   
}
