# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0"

  backend "s3" {
    bucket = "your-terraform-state-bucket" # Replace with your bucket name
    key    = "react-app/terraform.tfstate"
    region = "us-east-1" # Update with your desired region
    encrypt = true
    dynamodb_table = "terraform-locks"      # Optional DynamoDB table for state locking
  }
}

provider "aws" {
  region = "us-east-1" # Update with your desired region
}

# Data block to get latest AMI ID for Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



# VPC Module
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "react-app-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Replace with desired AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "react-app-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Replace with desired AZ
  map_public_ip_on_launch = true
  tags = {
    Name = "react-app-public-subnet-2"
  }
}


resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a" # Replace with desired AZ
  tags = {
    Name = "react-app-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b" # Replace with desired AZ
  tags = {
    Name = "react-app-private-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "react-app-igw"
  }
}

# Route Table for Public Subnets
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

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  name        = "react-app-alb-sg"
  description = "Allow traffic to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to known IPs in production.
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to known IPs in production.
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "react-app-alb-sg"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "react-app-ec2-sg"
  description = "Allow traffic to the EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP"] # Restrict SSH access!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "react-app-ec2-sg"
  }
}


resource "aws_security_group" "rds_sg" {
  name        = "react-app-rds-sg"
  description = "Allow traffic to the RDS database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432 # Postgres default port - adjust for your DB
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # From EC2 instances
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "react-app-rds-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "react-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app_tg" {
  name     = "react-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path     = "/"  # Adjust health check path as needed
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


#Launch Template
resource "aws_launch_template" "react_app_launch_template" {
  name_prefix   = "react-app-launch-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  key_name      = "your-ssh-key-name" # Replace with your SSH key name

  network_interface {
    security_groups = [aws_security_group.ec2_sg.id]
    subnet_id      = aws_subnet.private_subnet_1.id # Launch EC2 in first private subnet
  }

  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y nodejs npm
# Install PM2 globally
sudo npm install -g pm2
# Clone your React app
git clone <YOUR_REACT_APP_REPO> /home/ubuntu/react-app
cd /home/ubuntu/react-app
npm install
npm run build

# Serve the built app with pm2
pm2 start serve -s build -l /home/ubuntu/react-app/logs/pm2.log -n react-app
EOF
  )


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "react-app-instance"
    }
  }

  # Block device mappings (e.g., for adding more storage)
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30  # Increase if you need more space
      volume_type = "gp3"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "react-app-asg"
  launch_template {
    id      = aws_launch_template.react_app_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 3

  health_check_type         = "ELB"

  tag {
    key                 = "Name"
    value               = "react-app-instance"
    propagate_at_launch = true
  }
}

# RDS Database (PostgreSQL)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "react-app-rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id] # Important: Use private subnets

  tags = {
    Name = "react-app-rds-subnet-group"
  }
}


resource "aws_db_instance" "default" {
  allocated_storage    = 20 # Adjust storage as needed
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.medium"
  name                 = "reactappdb"
  username             = "admin"
  password             = "YOUR_DB_PASSWORD" # Use a secret management solution in production!
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible  = false
  skip_final_snapshot  = true # Remove in production!  Takes a snapshot before termination
  multi_az = false
  storage_type = "gp2" # General Purpose SSD

}

# S3 Bucket for Static Assets (and Terraform state)
resource "aws_s3_bucket" "static_assets" {
  bucket = "your-react-app-static-assets" # Replace with a globally unique name

  tags = {
    Name = "react-app-static-assets"
  }
}

resource "aws_s3_bucket_public_access_block" "static_assets_block" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Distribution for Static Assets
resource "aws_cloudfront_distribution" "static_assets_cf" {
  origin {
    domain_name = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id   = "s3origin"

     s3_origin_config {
       origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
     }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html" # Adjust as needed.
  aliases             = ["your-react-app.com"] # Replace with your domain


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600 # One hour
    max_ttl                = 86400 # One day
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:YOUR_ACCOUNT_ID:certificate/YOUR_CERTIFICATE_ID" # Required when using aliases.
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method         = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "OAI for react-app-static-assets"
}

# IAM role for EC2 instances (replace with more specific permissions)
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid   = ""
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2-policy"
  description = "Policy for EC2 to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          aws_s3_bucket.static_assets.arn,
          "${aws_s3_bucket.static_assets.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

output "application_url" {
  value = aws_lb.app_lb.dns_name
  description = "The URL of the application"
}

output "cloudfront_domain" {
 value = aws_cloudfront_distribution.static_assets_cf.domain_name
 description = "The CloudFront domain for static assets"
}