# Public Load Balancer (ALB)
resource "aws_lb" "public_lb" {
  count              = var.include_load_balancer == "yes" ? 1 : 0
  name               = "${var.owner}-${var.project_name}-public-lb"
  internal           = false
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id
  enable_deletion_protection = false
  load_balancer_type = "application" # ALB

  tags = {
    Name = "${var.owner}-${var.project_name}-public-lb"
  }
}

# Private Load Balancer (Converted to NLB)
resource "aws_lb" "private_nlb" {
  count              = var.include_load_balancer == "yes" ? 1 : 0
  name               = "${var.owner}-${var.project_name}-private-nlb"
  internal           = true
  subnets            = aws_subnet.private_subnets[*].id
  load_balancer_type = "network" # Changed to NLB
  enable_deletion_protection = false

  tags = {
    Name = "${var.owner}-${var.project_name}-private-nlb"
  }
}

# Target Groups
resource "aws_lb_target_group" "public_target_group" {
  count = var.include_load_balancer == "yes" ? 1 : 0

  name        = "${var.owner}-${var.project_name}-public-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/health?ready=1"
    protocol            = "HTTP"
    interval            = 5
    timeout             = 4
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.owner}-${var.project_name}-public-tg"
  }
}

# Private Target Group (TCP for CockroachDB)
resource "aws_lb_target_group" "private_target_group" {
  count = var.include_load_balancer == "yes" ? 1 : 0

  name        = "${var.owner}-${var.project_name}-private-tg"
  port        = 26257 # CockroachDB TCP port
  protocol    = "TCP" # Changed from HTTP to TCP
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/health?ready=1" # CockroachDB health check
    protocol            = "HTTP" # Use HTTP for health checks
    port                = 8080 # Target the HTTP admin port
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.owner}-${var.project_name}-private-tg"
  }
}

# Listeners
resource "aws_lb_listener" "public_listener" {
  count = var.include_load_balancer == "yes" ? 1 : 0

  load_balancer_arn = aws_lb.public_lb[0].arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_target_group[0].arn
  }
}

resource "aws_lb_listener" "private_listener" {
  count = var.include_load_balancer == "yes" ? 1 : 0

  load_balancer_arn = aws_lb.private_nlb[0].arn
  port              = 26257
  protocol          = "TCP" # Changed from HTTP to TCP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_target_group[0].arn
  }
}

# Target Group Attachments for CRDB Instances
resource "aws_lb_target_group_attachment" "public_tg_attachment" {
  count = var.include_load_balancer == "yes" ? var.crdb_nodes : 0

  target_group_arn = aws_lb_target_group.public_target_group[0].arn
  target_id        = aws_instance.crdb[count.index].id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "private_tg_attachment" {
  count = var.include_load_balancer == "yes" ? var.crdb_nodes : 0

  target_group_arn = aws_lb_target_group.private_target_group[0].arn
  target_id        = aws_instance.crdb[count.index].id
  port             = 26257 # Changed from 8080 to 26257 for CockroachDB
}

