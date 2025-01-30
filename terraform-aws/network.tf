# -----------------------------------------------------------------------
# Create VPC, IGW, subnets (public and private),  route tables (public and private) and routes.
# -----------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge(local.tags, {Name = "${var.owner}-${var.project_name}-vpc"})
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = local.tags
}

resource "aws_subnet" "public_subnets" {
  count              = 3

  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.availability_zone_list[count.index]
  cidr_block              = local.public_subnet_list[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.tags, {Name = "${var.owner}-${var.project_name}-public-sn"})
}

# this object map is for nothing more than being able to easily retrieve the availability zone and region
# when building the instance (the avialability zone is no longer available from the network interface).
locals {
  subnet_map = { for i, subnet in aws_subnet.public_subnets :
    subnet.id => {
      id   = subnet.id
      cidr = subnet.cidr_block
      availability_zone = subnet.availability_zone
      region = substr(subnet.availability_zone,0,length(subnet.availability_zone)-1)
    }
  }
}

resource "aws_subnet" "private_subnets" {
  count              = 3

  vpc_id            = aws_vpc.main.id
  availability_zone = local.availability_zone_list[count.index]
  cidr_block        = local.private_subnet_list[count.index]
  tags = merge(local.tags, {Name = "${var.owner}-${var.project_name}-private-sn"})
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, {Name = "${var.owner}-${var.project_name}-public-rt"})

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags,{Name = "${var.owner}-${var.project_name}-private-rt"})
}

resource "aws_route_table_association" "public_route_table" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id 
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id 
  route_table_id = aws_route_table.private_route_table.id   
}


# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest#input_ingress_with_self
# https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/examples/complete/main.tf
module "security-group-01" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "${var.owner}-${var.project_name}-sg01"
  description = "Allow desktop access (SSH, RDP, Database, HTTP, Kafka) to EC2 instances"
  tags        = local.tags
  vpc_id      = aws_vpc.main.id

  # Combine whitelist IPs with my own IP
  # ingress_cidr_blocks = tolist(concat(var.whitelist_ips, [var.my_ip_address]))
  ingress_cidr_blocks = concat(var.whitelist_ips,["${var.my_ip_address}/32"])

  ingress_with_cidr_blocks = [
    {
      from_port   = 26257
      to_port     = 26257
      protocol    = "tcp"
      description = "Allow CockroachDB access from my IP"
    },
    {
      rule        = "ssh-tcp"
      description = "Allow SSH access"
    },
    {
      rule        = "http-8080-tcp"
      description = "Allow HTTP access on port 8080"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "Allow RDP over TCP"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "udp"
      description = "Allow RDP over UDP"
    },
    {
      from_port   = 9021
      to_port     = 9021
      protocol    = "tcp"
      description = "Allow Confluent Control Center access"
    },
    {
      from_port   = 8083
      to_port     = 8083
      protocol    = "tcp"
      description = "Allow Kafka Connect access"
    }
  ]

  egress_rules = ["all-all"]
}

module "security-group-02" {
  # https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name = "${var.owner}-${var.project_name}-sg02"
  description = "Allow Intra-node communication"
  tags = local.tags

  # This creates a rule to allow all ingress on all ports of all types for anything in this security group
  ingress_with_self = [{rule = "all-all"}]
  # This creates a rule to allow all egress 
  egress_rules = ["all-all"]
  vpc_id = aws_vpc.main.id
}

# allow the load balancer to reach cockroachdb
resource "aws_security_group_rule" "http_from_vpc" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "http"
  cidr_blocks              = [var.vpc_cidr]
  description              = "Allow HTTP traffic from Load Balancer"
  security_group_id        = module.security-group-02.security_group_id 
}

resource "aws_security_group_rule" "cockroachdb_from_vcp" {
  type                     = "ingress"
  from_port                = 26257
  to_port                  = 26257
  protocol                 = "tcp"
  cidr_blocks              = [var.vpc_cidr]
  description              = "Allow CockroachDB traffic from vpc"
  security_group_id        = module.security-group-02.security_group_id 
}

# allow the app node to reach the load balancer
resource "aws_security_group_rule" "http_to_vpc" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  cidr_blocks              = [var.vpc_cidr]
  description              = "Allow HTTP traffic to Load Balancer"
  security_group_id = aws_security_group.lb_security_group.id
}

resource "aws_security_group_rule" "crdb_to_vpc" {
  type                     = "ingress"
  from_port                = 26257
  to_port                  = 26257
  protocol                 = "tcp"
  cidr_blocks              = [var.vpc_cidr]
  description              = "Allow crdb traffic to Load Balancer"
  security_group_id = aws_security_group.lb_security_group.id
}

# Security Group for Load Balancer
resource "aws_security_group" "lb_security_group" {

  name        = "${var.owner}-${var.project_name}-lb-sg"
  description = "Security group for Load Balancer"
  vpc_id      =  aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 26257
    to_port     = 26257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.owner}-${var.project_name}-lb-sg"
  }
}

# AWS Network Interfaces - 1 Per CRDB Node
# I need all of the private IP addresses before creating the nodes
# so that I can assemble the join string and set up ssh between the nodes
resource "aws_network_interface" "crdb" {
  tags                  = local.tags
  count                 = var.crdb_nodes
  subnet_id             = aws_subnet.public_subnets[count.index % 3].id
  # when creating network interfaces, the security group must go here, not in the instance config
  security_groups = [module.security-group-02.security_group_id, module.security-group-01.security_group_id]
}

# This object map allows me to look up the information stored on the subnet_map in ther instance resource
locals {
  interface_map = { for i, interface in aws_network_interface.crdb :
    interface.id => {
      id   = interface.id
      subnet_id = interface.subnet_id
      private_ip = interface.private_ip
    }
  }
}


# Always create the haproxy network interface, even if it is not going to be used.
# This is required for adding the ip address to the node cert.  The code that adds
# the node cert, cannot know if the haproxy is required or not.
resource "aws_network_interface" "haproxy" {
  tags                  = local.tags
  count                 = 1
  subnet_id             = aws_subnet.public_subnets[0].id
  # when creating network interfaces, the security group must go here, not in the instance config
  security_groups = [module.security-group-02.security_group_id, module.security-group-01.security_group_id]
}
resource "aws_network_interface" "app" {
  tags                  = local.tags
  count                 = 1
  subnet_id             = aws_subnet.public_subnets[0].id
  # when creating network interfaces, the security group must go here, not in the instance config
  security_groups = [module.security-group-02.security_group_id, module.security-group-01.security_group_id]
}
resource "aws_network_interface" "kafka" {
  tags                  = local.tags
  count                 = 1
  subnet_id             = aws_subnet.public_subnets[0].id
  # when creating network interfaces, the security group must go here, not in the instance config
  security_groups = [module.security-group-02.security_group_id, module.security-group-01.security_group_id]
}
