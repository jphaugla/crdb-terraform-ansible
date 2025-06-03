resource "aws_security_group" "lb_sg" {
  name        = "${var.owner}-${var.project_name}-lb-sg"
  description = "Security group for Load Balancer"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.tags, { Name = "${var.owner}-${var.project_name}-lb-sg" })

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow public HTTP to LB"
  }

  ingress {
    from_port   = 26257
    to_port     = 26257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow public CRDB to LB (if needed)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
}
