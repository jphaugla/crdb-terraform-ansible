module "sg_kafka" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "${var.owner}-${var.project_name}-sg-kafka"
  description = "Allow Kafka  and Confluent C3  from trusted IPs"
  vpc_id      = aws_vpc.main.id
  tags        = local.tags

  ingress_cidr_blocks = concat(var.netskope_ips, ["${var.my_ip_address}/32"])

  ingress_with_cidr_blocks = [
    {
      # Kafka broker + Connect share contiguous ports 8082–8083 
      from_port   = 8082
      to_port     = 8083
      protocol    = "tcp"
      description = "Allow Kafka  from trusted IPs"
    },
    {
      from_port   = 9021
      to_port     = 9021
      protocol    = "tcp"
      description = "Allow Confluent Control Center 9021"
    },
  ]

  egress_rules = ["all-all"]
}

