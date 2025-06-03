module "sg_management" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "${var.owner}-${var.project_name}-sg-management"
  description = "Allow SSH and RDP from trusted IPs"
  vpc_id      = aws_vpc.main.id
  tags        = local.tags

  ingress_cidr_blocks = concat(var.netskope_ips, ["${var.my_ip_address}/32"])

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      description = "Allow SSH from trusted IPs"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "Allow RDP TCP"
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "udp"
      description = "Allow RDP UDP"
    },
  ]

  egress_rules = ["all-all"]
}

