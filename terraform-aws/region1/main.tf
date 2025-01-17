module "my_aws" {
   source      = "../"
   my_ip_address = "174.141.204.193"
   aws_region_01 = "us-east-2"
   owner = "jhaug"
   project_name = "east2"
   crdb_instance_key_name = "jph-cockroach-us-east-2-kp01"
   vpc_cidr = "192.168.6.0/24"

# -----------------------------------------
# CRDB Specifications
# -----------------------------------------
   crdb_nodes = 3
   crdb_instance_type = "t4g.medium"
   crdb_store_volume_type = "gp3"
   crdb_store_volume_size = 8
   crdb_version = "24.3.0"
   crdb_arm_release = "yes"
   crdb_enable_spot_instances = "no"
   
# HA Proxy
   include_ha_proxy = "yes"
   haproxy_instance_type = "t3a.micro"

# APP Node
   include_app = "yes"
   app_instance_type = "t3a.micro"

   create_admin_user = "yes"
   admin_user_name = "jhaugland"
}
