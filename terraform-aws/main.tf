data "aws_availability_zones" "available" {
  state = "available"
}

# aws ec2 describe-images --region us-east-2 --filters "Name=name, Values=al2023-ami-2023*"
data "aws_ami" "amazon_linux_2023_x64" {
 most_recent = true
 owners = ["amazon"]
 filter {
   name   = "name"
   values = ["al2023-ami-2023*"]
 }
 filter {
      name = "architecture"
      values = [ "x86_64" ]
  }
  filter {
      name = "virtualization-type"
      values = [ "hvm" ]
  }
}

data "aws_ami" "amazon_linux_2023_arm" {
 most_recent = true
 owners = ["amazon"]
 filter {
   name   = "name"
   values = ["al2023-ami-2023*"]
 }
 filter {
    name = "architecture"
    values = [ "arm64" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

data "aws_ami" "ubuntu_22_04_gen2" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-2025*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  required_tags = {
    owner       = var.owner,
    project     = var.project_name,
  }
  tags = merge(var.resource_tags, local.required_tags) 
  admin_username = "ec2-user"
  # create 6 subnets: 3 for public subnets, 3 for private subnets
  subnet_list = cidrsubnets(var.vpc_cidr,3,3,3,3,3,3)
  private_subnet_list = chunklist(local.subnet_list,3)[0]
  public_subnet_list  = chunklist(local.subnet_list,3)[1]
 # maximum AZs we want to consume
  desired_az_count = 3

  # how many AZ names are actually returned here?
  actual_az_count = length(data.aws_availability_zones.available.names)

  # slice_end = min(actual_az_count, desired_az_count)
  slice_end = (
    local.actual_az_count < local.desired_az_count
  ) ? local.actual_az_count : local.desired_az_count

  availability_zone_list = slice(
    data.aws_availability_zones.available.names,
    0,
    local.slice_end
  )
}
  
locals {
#  depends_on = [aws_network_interface.crdb]
  ip_list     = join(" ", aws_network_interface.crdb[*].private_ip)
  join_string = (var.join_string != "" ? var.join_string : join(",", aws_network_interface.crdb[*].private_ip))
}

locals {
  # depends_on = [aws_instance.crdb]
  ip_list_public     = join(" ", aws_instance.crdb[*].public_ip)
  join_string_public = (var.join_string != "" ? var.join_string : join(",", aws_instance.crdb[*].public_ip))
  prometheus_string = (var.prometheus_string != "" ? var.prometheus_string : join(",", formatlist("%s:8080", aws_network_interface.crdb[*].private_ip)))
  prometheus_app_string = (var.prometheus_app_string != "" ? var.prometheus_app_string : join(",", formatlist("%s:30005", aws_network_interface.app[*].private_ip)))
}

locals {
  ami_id      = (var.crdb_arm_release == "no" ?  "${data.aws_ami.amazon_linux_2023_x64.id}" : "${data.aws_ami.amazon_linux_2023_arm.id}")
}

# ----------------------------------------
# The following was created to account for NetSkope Tunneling  
# ----------------------------------------
variable netskope_ips {
  description = "A list of IP CIDR ranges to allow as clients.  The IPs listed below are Netskope IP Ranges"
  default     = ["8.36.116.0/24" ,"8.39.144.0/24", "31.186.239.0/24", "163.116.128.0/17", "162.10.0.0/17"]
  type        = list(string)
}
