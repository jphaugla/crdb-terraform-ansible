################################################################################
# terraform-aws/s3.tf
#
# Each region’s S3 bucket and IAM role/profile must include virtual_network_location
# so names are unique per region.
################################################################################
################################################################################
# terraform-aws/s3.tf
################################################################################
locals {
  bucket_name = "${var.owner}-${var.project_name}-${var.virtual_network_location}-molt-bucket"
}

resource "aws_s3_bucket" "molt_bucket" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = { Name = local.bucket_name }
}

resource "aws_s3_object" "incoming_directory" {
  bucket  = aws_s3_bucket.molt_bucket.id
  key     = "incoming/"
  content = ""
}

resource "aws_s3_bucket_policy" "molt_bucket_policy" {
  bucket = aws_s3_bucket.molt_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowReadWriteFromMyIP",
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:ListBucket","s3:GetObject","s3:PutObject","s3:DeleteObject"],
        Resource  = [aws_s3_bucket.molt_bucket.arn, "${aws_s3_bucket.molt_bucket.arn}/*"],
        Condition = {
          IpAddress = { "aws:SourceIp" : [var.my_ip_address, var.vpc_cidr] }
        }
      }
    ]
  })
}

# ---------------------------
# IAM (conditionally created)
# ---------------------------

resource "aws_iam_role" "ec2_s3_role" {
  count = var.enable_s3_iam ? 1 : 0
  name  = "${var.owner}-${var.project_name}-${var.virtual_network_location}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_policy" {
  count = var.enable_s3_iam ? 1 : 0
  name  = "${var.owner}-${var.project_name}-${var.virtual_network_location}-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect  = "Allow",
      Action  = ["s3:ListBucket","s3:GetObject","s3:PutObject","s3:DeleteObject"],
      Resource = [aws_s3_bucket.molt_bucket.arn, "${aws_s3_bucket.molt_bucket.arn}/*"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  count      = var.enable_s3_iam ? 1 : 0
  role       = aws_iam_role.ec2_s3_role[0].name
  policy_arn = aws_iam_policy.s3_policy[0].arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  count = var.enable_s3_iam ? 1 : 0
  name  = "${var.owner}-${var.project_name}-${var.virtual_network_location}-instance-profile"
  role  = aws_iam_role.ec2_s3_role[0].name
}

