module "my_aws" {
   source      = "../"
   my_ip_address = "174.141.204.193"
   virtual_network_location = "us-east-2"
   owner = "jhaug"
   project_name = "east2"
   crdb_instance_key_name = "jph-cockroach-us-east-2-kp01"
   ssh_private_key              = "~/.ssh/jph-cockroach-us-east-2-kp01.pem"
   vpc_cidr = "192.168.6.0/24"

# -----------------------------------------
# CRDB Specifications
# -----------------------------------------
   crdb_nodes = 3
   #   this is a very small 2vcpu 4GB ram machine for functionality
   # crdb_instance_type = "t4g.medium"
   crdb_instance_type = "t4g.xlarge"
   crdb_store_volume_type = "gp3"
   crdb_store_volume_size = 8
   crdb_version = "25.1.0"
   crdb_arm_release = "yes"
   crdb_enable_spot_instances = "no"
   crdb_file_location         = "/mnt/data"
# ----------------------------------------
# Cluster Location Data - For console map
# ----------------------------------------
   install_system_location_data = "yes"
# ----------------------------------------
# Allow non-TLS connections
# ----------------------------------------
  allow_non_tls              = true
# HA Proxy
   include_ha_proxy = "yes"
   haproxy_instance_type = "t3a.large"
# kafka
   include_kafka = "no"
   kafka_instance_type = "t3a.xlarge"
# APP Node
   include_app = "yes"
   app_instance_type = "t3a.xlarge"
   create_dbadmin_user = "yes"
   setup_migration           = "yes"
   dbadmin_user_name          = "jhaugland"
   dbadmin_user_password      = "jasonrocks"
# ----------------------------------------
# Cluster Enterprise License Keys
# ----------------------------------------
# Be sure to do the following in your environment if you plan on installing the license keys
# must add the enterprise licence and the cluster organization to specified subdirectory
#  ${full_path_license_directory}/enterprise_licence
#  ${full_path_license_directory}/cluster_organization
   full_path_license_directory = "/Users/jasonhaugland/.crdb/"
# ----------------------------------------
# Create Network load balancer
# ----------------------------------------
   include_load_balancer           = "yes"
}
