terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# ------------------------------------------------------------------------------
# VPC Module
# ------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------------------------------------------------------
# Security Group
# ------------------------------------------------------------------------------

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere (VERY INSECURE - ONLY FOR DEMO)"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_tls"
  }
}

# ------------------------------------------------------------------------------
# EC2 Instance
# ------------------------------------------------------------------------------

resource "aws_instance" "app_server" {
  ami           = "ami-0c55b628f6b893d29" # Replace with latest Ubuntu AMI for us-east-1
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]

  tags = {
    Name = "app-server"
  }

  # IMPORTANT:  Replace with a proper key pair!
  key_name = "REPLACE_WITH_KEYPAIR_NAME"

  # For demonstration only.  Proper deployment would involve configuration management
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Hello from Terraform!</h1>" | sudo tee /var/www/html/index.html
              EOF
}

# ------------------------------------------------------------------------------
# S3 Bucket for Frontend
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "bucket" {
  bucket = "your-unique-bucket-name" # Replace with a unique bucket name

  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private" #IMPORTANT: Enforce private access to allow use of CloudFront OAC
}


# Block all public access to the S3 bucket.
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# CloudFront Distribution
# ------------------------------------------------------------------------------
# Note that this will require an ACM certificate for proper SSL

resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "origin-access-control"
  description                       = "Origin Access Control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "s3origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

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
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # MUST REPLACE WITH VALID ACM CERT
  }

 tags = {
    Environment = "production"
  }
}

# ------------------------------------------------------------------------------
# Database (RDS PostgreSQL)
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet_a.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  db_name              = "mydb"
  engine               = "postgres"
  engine_version       = "15.3" #or latest
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "REPLACE_WITH_SECURE_PASSWORD" # DO NOT HARDCODE IN PRODUCTION
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.allow_tls.id]  #Important:  configure with proper ports

  skip_final_snapshot = true

  tags = {
    Name = "mydb"
  }
}

#Outputs
output "cloudfront_domain" {
  value = try(aws_cloudfront_distribution.s3_distribution.domain_name, "N/A")
  description = "cloudfront_domain"
}