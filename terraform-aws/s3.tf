locals {
  bucket_name = "${var.owner}-${var.project_name}-molt-bucket"
}
resource "aws_s3_bucket" "molt_bucket" {
  bucket = local.bucket_name
  force_destroy = true
  tags = {
    Name = local.bucket_name
  }
}

# Create an empty object to mimic an "incoming" directory
resource "aws_s3_object" "incoming_directory" {
  bucket  = aws_s3_bucket.molt_bucket.id
  key     = "incoming/"   # trailing slash simulates a directory
  content = ""
}

resource "aws_s3_bucket_policy" "molt_bucket_policy" {
  bucket = aws_s3_bucket.molt_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowReadWriteFromMyIP",
        Effect   = "Allow",
        Principal = "*",
        Action   = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          aws_s3_bucket.molt_bucket.arn,
          "${aws_s3_bucket.molt_bucket.arn}/*"
        ],
        Condition = {
          IpAddress = {
            "aws:SourceIp": [
              var.my_ip_address,   // Your local machine’s public IP in CIDR notation (e.g., "203.0.113.45/32")
              var.vpc_cidr         // The CIDR block of your VPC (e.g., "10.0.0.0/16")
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.owner}-${var.project_name}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name   = "${var.owner}-${var.project_name}-s3-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      Resource = [
        aws_s3_bucket.molt_bucket.arn,
        "${aws_s3_bucket.molt_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.owner}-${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

