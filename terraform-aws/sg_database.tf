module "sg_database" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "${var.owner}-${var.project_name}-sg-database"
  description = "Allow CockroachDB and Postgres from trusted IPs"
  vpc_id      = aws_vpc.main.id
  tags        = local.tags

  ingress_cidr_blocks = concat(var.netskope_ips, ["${var.my_ip_address}/32"])

  ingress_with_cidr_blocks = [
    {
      from_port   = 26257
      to_port     = 26257
      protocol    = "tcp"
      description = "Allow CockroachDB access from trusted IPs"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Allow CockroachDB console access from trusted IPs"
    },
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Allow Postgres from trusted IPs"
    },
  ]

  egress_rules = ["all-all"]
}
