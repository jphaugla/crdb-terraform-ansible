# network.tf

# 1) Fetch available AZs
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# # 2) Build a capped list of AZs
# locals {
#   desired_az_count = 3
#   actual_az_count  = length(data.aws_availability_zones.available.names)
# 
#   # we only want as many AZs as AWS actually provides, up to desired_az_count
#   slice_end = (
#     local.actual_az_count < local.desired_az_count
#   ) ? local.actual_az_count : local.desired_az_count
# 
#   availability_zone_list = slice(
#     data.aws_availability_zones.available.names,
#     0,
#     local.slice_end
#   )
# }

# 3) VPC, subnets, and route tables

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, {
    Name = "${var.owner}-${var.project_name}-vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

resource "aws_subnet" "public_subnets" {
  count                    = 3
  vpc_id                   = aws_vpc.main.id
  availability_zone        = local.availability_zone_list[count.index]
  cidr_block               = local.public_subnet_list[count.index]
  map_public_ip_on_launch  = true

  tags = merge(local.tags, {
    Name = "${var.owner}-${var.project_name}-public-sn-${count.index}"
  })
}

resource "aws_subnet" "private_subnets" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  availability_zone = local.availability_zone_list[count.index]
  cidr_block        = local.private_subnet_list[count.index]

  tags = merge(local.tags, {
    Name = "${var.owner}-${var.project_name}-private-sn-${count.index}"
  })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, {
    Name = "${var.owner}-${var.project_name}-public-rt"
  })

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, {
    Name = "${var.owner}-${var.project_name}-private-rt"
  })
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# 4) Network Interfaces: CRDB, HAProxy, App, Kafka

resource "aws_network_interface" "crdb" {
  count           = var.crdb_nodes
  subnet_id       = aws_subnet.public_subnets[count.index].id
  security_groups = [
    module.security_group_intra.security_group_id,
    module.sg_database.security_group_id,
    module.sg_management.security_group_id,
  ]
  tags = local.tags
}

resource "aws_network_interface" "haproxy" {
  count           = 1
  subnet_id       = aws_subnet.public_subnets[0].id
  security_groups = [
    module.security_group_intra.security_group_id,
    module.sg_application.security_group_id,
    module.sg_management.security_group_id,
  ]
  tags = local.tags
}

resource "aws_network_interface" "app" {
  count           = 1
  subnet_id       = aws_subnet.public_subnets[0].id
  security_groups = [
    module.security_group_intra.security_group_id,
    module.sg_management.security_group_id,
    module.sg_application.security_group_id,
  ]
  tags = local.tags
}

resource "aws_network_interface" "kafka" {
  count           = 1
  subnet_id       = aws_subnet.public_subnets[0].id
  security_groups = [
    module.security_group_intra.security_group_id,
    module.sg_kafka.security_group_id,
    module.sg_management.security_group_id,
  ]
  tags = local.tags
}

