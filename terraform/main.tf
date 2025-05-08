terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# -----------------------------------------------------------------------------
#  VPC
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "react-app-vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Replace with your desired AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "react-app-public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Replace with your desired AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "react-app-public-subnet-b"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a" # Replace with your desired AZ
  tags = {
    Name = "react-app-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b" # Replace with your desired AZ
  tags = {
    Name = "react-app-private-subnet-b"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "react-app-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "react-app-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# -----------------------------------------------------------------------------
#  Security Groups
# -----------------------------------------------------------------------------
resource "aws_security_group" "allow_alb" {
  name        = "allow_alb"
  description = "Allow traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_alb"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow traffic to web servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_alb.id]
  }

   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_alb.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_ADDRESS/32"]  # Replace with your IP for SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow traffic to database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432  # PostgreSQL default port
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_db"
  }
}

# -----------------------------------------------------------------------------
#  ALB
# -----------------------------------------------------------------------------
resource "aws_lb" "alb" {
  name               = "react-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_alb.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  enable_deletion_protection = false

  tags = {
    Name = "react-app-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "react-app-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path     = "/"
    protocol = "HTTP"
    matcher  = "200-399"
  }
}

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:YOUR_ACCOUNT_ID:certificate/YOUR_CERTIFICATE_ID" # Replace with your ACM certificate ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

# -----------------------------------------------------------------------------
#  EC2 Instances & Auto Scaling
# -----------------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "web_lt" {
  name_prefix   = "react-app-web-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.medium"
  key_name = "YOUR_KEY_PAIR_NAME" # Replace with your key pair name
  security_group_names = [aws_security_group.allow_web.name]

  network_interfaces {
    subnet_id             = aws_subnet.private_subnet_a.id # Deploying to private subnet
    associate_public_ip_address = false # Remove if you need to deploy to a public subnet with direct internet access
    security_groups       = [aws_security_group.allow_web.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd git
sudo systemctl start httpd
sudo systemctl enable httpd
# Clone your react app code
git clone YOUR_REACT_APP_GIT_REPO /var/www/html
# Update .env file with the configuration
# Or provide required env variables with echo command
# Install dependencies and build your app
sudo yum install -y nodejs
cd /var/www/html
npm install
npm run build
# Copy the build to the httpd folder
sudo cp -r /var/www/html/build/* /var/www/html/
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "react-app-web-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                      = "react-app-web-asg"
  max_size                  = 3
  min_size                  = 2
  desired_capacity        = 2
  vpc_zone_identifier       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id] # Deploying to private subnets

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.alb_tg.arn]

  health_check_type = "ELB" # Use ELB health checks
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "react-app-web-server"
    propagate_at_launch = true
  }
}

# -----------------------------------------------------------------------------
#  RDS PostgreSQL Database
# -----------------------------------------------------------------------------
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "react-app-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = {
    Name = "react-app-db-subnet-group"
  }
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "react-app-db-cluster"
  engine                    = "aurora-postgresql" # Choose either "postgres" or "aurora-postgresql"
  engine_version            = "15.4"             # Specify Postgres version
  master_username           = "postgres"
  master_password           = "YOUR_DB_PASSWORD" # Replace with a secure password, preferably pulled from Secrets Manager
  db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.allow_db.id]
  skip_final_snapshot       = true # Remove or set to false in production
  availability_zones        = ["us-east-1a", "us-east-1b"]
  backup_retention_period = 5 # Specify backup retention in days
  preferred_backup_window = "07:00-09:00" # Specify the backup window
  preferred_maintenance_window = "Tue:17:00-Tue:19:00" # Specify the maintenance window

  tags = {
    Name = "react-app-db-cluster"
  }

  lifecycle {
    ignore_changes = [master_password]
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2  # number of instances
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.t3.medium" # Specify the instance class
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  availability_zone  = element(["us-east-1a", "us-east-1b"], count.index)
}
# -----------------------------------------------------------------------------
#  S3 Bucket for Static Assets
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "static_assets" {
  bucket = "your-react-app-static-assets" # Replace with a unique bucket name
  acl    = "private" # Important for security

  tags = {
    Name = "react-app-static-assets"
  }

  # Enable versioning
  versioning {
    enabled = true
  }

  # Enable server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# -----------------------------------------------------------------------------
#  CloudFront Distribution for S3
# -----------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id   = "s3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"  # Ensure this is configured correctly based on your app

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Configure custom error pages if needed
  custom_error_response {
    error_code            = 404
    response_code         = 200  # Serve index.html for 404
    response_page_path    = "/index.html"
  }

  # Add more cache behaviors based on your requirements.  E.g., for /api/*
  price_class = "PriceClass_100" # Choose the appropriate price class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # Or use an ACM certificate.
    #  acm_certificate_arn            = "arn:aws:acm:us-east-1:YOUR_ACCOUNT_ID:certificate/YOUR_CERTIFICATE_ID" # Optional: Use an ACM certificate for HTTPS
    #  minimum_protocol_version = "TLSv1.2_2021"
    #  ssl_support_method         = "sni-only"

  }
}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for react-app-static-assets"
}

#S3 Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "s3:GetObject",
        Effect   = "Allow",
        Principal = {
          "AWS" = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        },
        Resource = "${aws_s3_bucket.static_assets.arn}/*"
      }
    ]
  })
}
# -----------------------------------------------------------------------------
#  IAM Role for EC2 Instances
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ec2_role" {
  name               = "react-app-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid = ""
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "react-app-ec2-policy"
  description = "Policy for EC2 instances to access S3 and CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.static_assets.arn,
          "${aws_s3_bucket.static_assets.arn}/*"
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}