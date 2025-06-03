module "security_group_intra" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "${var.owner}-${var.project_name}-sg-intra"
  description = "Allow intra VPC communication on HTTP+CRDB ports"
  vpc_id      = aws_vpc.main.id
  tags        = local.tags

  # Allow any host in the VPC (including NLB nodes) to talk to our CRDB on
  # 26257 (SQL) and 8080 (HTTP health UI).
  ingress_cidr_blocks = [ var.vpc_cidr ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 26257
      to_port     = 26257
      protocol    = "tcp"
      description = "Allow SQL (26257) from within VPC"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Allow HTTP (8080) from within VPC"
    },
  ]

  egress_rules = ["all-all"]
}
