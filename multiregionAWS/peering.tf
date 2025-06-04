################################################################################
# peering.tf
#
# VPC peering, routes, and security‐group rules for a 3‐region CockroachDB setup.
################################################################################

# ───────────────────────────────────────────────────────────────────────────────
# 1. PEERING CONNECTION BETWEEN region-0 and region-1
# ───────────────────────────────────────────────────────────────────────────────

# Create the peering connection from region-0 → region-1
resource "aws_vpc_peering_connection" "peer0" {
  provider    = aws.region-0
  vpc_id      = module.crdb-region-0.vpc_id
  peer_vpc_id = module.crdb-region-1.vpc_id
  peer_region = var.aws_region_list[1]
  auto_accept = false
  tags        = local.tags
}

# Accepter side in region-1 for peer0
resource "aws_vpc_peering_connection_accepter" "peer0" {
  provider                  = aws.region-1
  vpc_peering_connection_id = aws_vpc_peering_connection.peer0.id
  auto_accept               = true
}

# Route in region-0 pointing to region-1 CIDR
resource "aws_route" "vpc0-to-vpc1" {
  provider                   = aws.region-0
  route_table_id             = module.crdb-region-0.route_table_public_id
  destination_cidr_block     = var.vpc_cidr_list[1]
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer0.id
}

# Route in region-1 pointing to region-0 CIDR
resource "aws_route" "vpc1-to-vpc0" {
  provider                   = aws.region-1
  route_table_id             = module.crdb-region-1.route_table_public_id
  destination_cidr_block     = var.vpc_cidr_list[0]
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer0.id
}

# SG rule in region-0 allowing DB (26257) from region-1
resource "aws_vpc_security_group_ingress_rule" "into-vpc0-from-vpc1-db" {
  provider           = aws.region-0
  security_group_id  = module.crdb-region-0.security_group_intra_node_id
  from_port          = 26257
  to_port            = 26257
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[1]
  description        = "Allow CRDB (26257) from region-1"
}

# SG rule in region-0 allowing SSH (22) from region-1
resource "aws_vpc_security_group_ingress_rule" "into-vpc0-from-vpc1-ssh" {
  provider           = aws.region-0
  security_group_id  = module.crdb-region-0.security_group_intra_node_id
  from_port          = 22
  to_port            = 22
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[1]
  description        = "Allow SSH (22) from region-1"
}

# SG rule in region-1 allowing DB (26257) from region-0
resource "aws_vpc_security_group_ingress_rule" "into-vpc1-from-vpc0-db" {
  provider           = aws.region-1
  security_group_id  = module.crdb-region-1.security_group_intra_node_id
  from_port          = 26257
  to_port            = 26257
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[0]
  description        = "Allow CRDB (26257) from region-0"
}

# SG rule in region-1 allowing SSH (22) from region-0
resource "aws_vpc_security_group_ingress_rule" "into-vpc1-from-vpc0-ssh" {
  provider           = aws.region-1
  security_group_id  = module.crdb-region-1.security_group_intra_node_id
  from_port          = 22
  to_port            = 22
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[0]
  description        = "Allow SSH (22) from region-0"
}


# ───────────────────────────────────────────────────────────────────────────────
# 2. PEERING CONNECTION BETWEEN region-1 and region-2
# ───────────────────────────────────────────────────────────────────────────────

# Create the peering connection from region-1 → region-2
resource "aws_vpc_peering_connection" "peer1" {
  provider    = aws.region-1
  vpc_id      = module.crdb-region-1.vpc_id
  peer_vpc_id = module.crdb-region-2.vpc_id
  peer_region = var.aws_region_list[2]
  auto_accept = false
  tags        = local.tags
}

# Accepter side in region-2 for peer1
resource "aws_vpc_peering_connection_accepter" "peer1" {
  provider                  = aws.region-2
  vpc_peering_connection_id = aws_vpc_peering_connection.peer1.id
  auto_accept               = true
}

# Route in region-1 pointing to region-2 CIDR
resource "aws_route" "vpc1-to-vpc2" {
  provider                   = aws.region-1
  route_table_id             = module.crdb-region-1.route_table_public_id
  destination_cidr_block     = var.vpc_cidr_list[2]
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer1.id
}

# Route in region-2 pointing to region-1 CIDR
resource "aws_route" "vpc2-to-vpc1" {
  provider                   = aws.region-2
  route_table_id             = module.crdb-region-2.route_table_public_id
  destination_cidr_block     = var.vpc_cidr_list[1]
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer1.id
}

# SG rule in region-1 allowing DB (26257) from region-2
resource "aws_vpc_security_group_ingress_rule" "into-vpc1-from-vpc2-db" {
  provider           = aws.region-1
  security_group_id  = module.crdb-region-1.security_group_intra_node_id
  from_port          = 26257
  to_port            = 26257
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[2]
  description        = "Allow CRDB (26257) from region-2"
}

# SG rule in region-1 allowing SSH (22) from region-2
resource "aws_vpc_security_group_ingress_rule" "into-vpc1-from-vpc2-ssh" {
  provider           = aws.region-1
  security_group_id  = module.crdb-region-1.security_group_intra_node_id
  from_port          = 22
  to_port            = 22
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[2]
  description        = "Allow SSH (22) from region-2"
}

# SG rule in region-2 allowing DB (26257) from region-1
resource "aws_vpc_security_group_ingress_rule" "into-vpc2-from-vpc1-db" {
  provider           = aws.region-2
  security_group_id  = module.crdb-region-2.security_group_intra_node_id
  from_port          = 26257
  to_port            = 26257
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[1]
  description        = "Allow CRDB (26257) from region-1"
}

# SG rule in region-2 allowing SSH (22) from region-1
resource "aws_vpc_security_group_ingress_rule" "into-vpc2-from-vpc1-ssh" {
  provider           = aws.region-2
  security_group_id  = module.crdb-region-2.security_group_intra_node_id
  from_port          = 22
  to_port            = 22
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[1]
  description        = "Allow SSH (22) from region-1"
}


# ───────────────────────────────────────────────────────────────────────────────
# 3. PEERING CONNECTION BETWEEN region-2 and region-0
# ───────────────────────────────────────────────────────────────────────────────

# Create the peering connection from region-2 → region-0
resource "aws_vpc_peering_connection" "peer2" {
  provider    = aws.region-2
  vpc_id      = module.crdb-region-2.vpc_id
  peer_vpc_id = module.crdb-region-0.vpc_id
  peer_region = var.aws_region_list[0]
  auto_accept = false
  tags        = local.tags
}

# Accepter side in region-0 for peer2
resource "aws_vpc_peering_connection_accepter" "peer2" {
  provider                  = aws.region-0
  vpc_peering_connection_id = aws_vpc_peering_connection.peer2.id
  auto_accept               = true
}

# Route in region-2 pointing to region-0 CIDR
resource "aws_route" "vpc2-to-vpc0" {
  provider                   = aws.region-2
  route_table_id             = module.crdb-region-2.route_table_public_id
  destination_cidr_block     = var.vpc_cidr_list[0]
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer2.id
}

# Route in region-0 pointing to region-2 CIDR
resource "aws_route" "vpc0-to-vpc2" {
  provider                   = aws.region-0
  route_table_id             = module.crdb-region-0.route_table_public_id
  destination_cidr_block     = var.vpc_cidr_list[2]
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer2.id
}

# SG rule in region-2 allowing DB (26257) from region-0
resource "aws_vpc_security_group_ingress_rule" "into-vpc2-from-vpc0-db" {
  provider           = aws.region-2
  security_group_id  = module.crdb-region-2.security_group_intra_node_id
  from_port          = 26257
  to_port            = 26257
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[0]
  description        = "Allow CRDB (26257) from region-0"
}

# SG rule in region-2 allowing SSH (22) from region-0
resource "aws_vpc_security_group_ingress_rule" "into-vpc2-from-vpc0-ssh" {
  provider           = aws.region-2
  security_group_id  = module.crdb-region-2.security_group_intra_node_id
  from_port          = 22
  to_port            = 22
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[0]
  description        = "Allow SSH (22) from region-0"
}

# SG rule in region-0 allowing DB (26257) from region-2
resource "aws_vpc_security_group_ingress_rule" "into-vpc0-from-vpc2-db" {
  provider           = aws.region-0
  security_group_id  = module.crdb-region-0.security_group_intra_node_id
  from_port          = 26257
  to_port            = 26257
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[2]
  description        = "Allow CRDB (26257) from region-2"
}

# SG rule in region-0 allowing SSH (22) from region-2
resource "aws_vpc_security_group_ingress_rule" "into-vpc0-from-vpc2-ssh" {
  provider           = aws.region-0
  security_group_id  = module.crdb-region-0.security_group_intra_node_id
  from_port          = 22
  to_port            = 22
  ip_protocol        = "tcp"
  cidr_ipv4          = var.vpc_cidr_list[2]
  description        = "Allow SSH (22) from region-2"
}

