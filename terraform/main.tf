# Terraform Block: Define providers and required versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3"
}

# Provider Block: Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Variables: Define input variables for customization
variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "The custom domain name for the application (e.g., app.yourdomain.com)."
  type        = string
  # Example: default = "myapp.example.com" # Replace with your actual domain
}

variable "hosted_zone_name" {
  description = "The name of the Route 53 hosted zone (e.g., yourdomain.com)."
  type        = string
  # Example: default = "example.com" # Replace with your actual root domain
}

variable "project_name" {
  description = "A name for the project, used for tagging and resource naming."
  type        = string
  default     = "react-app"
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default = {
    Project     = "ReactApp"
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
  }
}

# --- S3 Bucket for Static Website Content ---
resource "aws_s3_bucket" "website_assets" {
  bucket = "${var.project_name}-assets-${random_id.bucket_suffix.hex}" # Ensures unique bucket name
  tags   = var.common_tags

  # It's good practice to enable versioning
  versioning {
    enabled = true
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Block all public access to the S3 bucket; CloudFront will use OAC
resource "aws_s3_bucket_public_access_block" "website_assets_public_access_block" {
  bucket = aws_s3_bucket.website_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- S3 Bucket for CloudFront Access Logs ---
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.project_name}-cf-logs-${random_id.bucket_suffix.hex}"
  tags   = var.common_tags

  lifecycle {
    prevent_destroy = false # Set to true in production if you want to keep logs
  }
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs_public_access_block" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- AWS Certificate Manager (ACM) for SSL/TLS ---
# This assumes your domain is managed in Route 53 for DNS validation.
# If not, you'll need to use email validation or manually create DNS records.
data "aws_route53_zone" "selected_zone" {
  name         = "${var.hosted_zone_name}." # Note the trailing dot
  private_zone = false
}

resource "aws_acm_certificate" "app_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_dns" {
  for_each = {
    for dvo in aws_acm_certificate.app_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.app_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_dns : record.fqdn]
}

# --- CloudFront Origin Access Control (OAC) ---
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "${var.project_name}-s3-oac"
  description                       = "OAC for S3 static website content"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- S3 Bucket Policy to allow CloudFront OAC ---
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_assets.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website_assets_policy" {
  bucket = aws_s3_bucket.website_assets.id
  policy = data.aws_iam_policy_document.s3_policy.json
}


# --- AWS WAFv2 Web ACL ---
resource "aws_wafv2_web_acl" "default" {
  name        = "${var.project_name}-web-acl"
  scope       = "CLOUDFRONT"
  description = "WAF WebACL for the ${var.project_name} application"

  default_action {
    allow {}
  }

  # Example: AWS Managed Rule - Common Rule Set
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  # Example: Rate-based rule to mitigate DDoS
  rule {
    name     = "${var.project_name}-RateLimitRule"
    priority = 2
    action {
      block {} # Or count {} for testing
    }
    statement {
      rate_based_statement {
        limit              = 2000 # Requests per 5-minute period per IP
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags
}


# --- CloudFront Distribution ---
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.project_name}"
  default_root_object = "index.html" # Assuming your React app's entry point is index.html

  origin {
    domain_name              = aws_s3_bucket.website_assets.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.website_assets.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_assets.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600  # 1 hour
    max_ttl                = 86400 # 24 hours

    # Cache policy for static assets (JS, CSS, Images)
    # Consider creating a specific cache policy for better control
    # cache_policy_id = aws_cloudfront_cache_policy.static_assets.id (example)

    # Enable compression for text-based assets
    compress = true
  }

  # If you have API routes like /api/* that should not be cached or go to a different origin
  # you would add ordered_cache_behavior blocks here.

  price_class = "PriceClass_100" # Use PriceClass_All for best performance, PriceClass_100 for cost saving

  restrictions {
    geo_restriction {
      restriction_type = "none" # Or "whitelist"/"blacklist" specific countries
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021" # Recommended for security
  }

  aliases = [var.domain_name]

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = "${var.project_name}-cf-access-logs/"
  }
  
  web_acl_id = aws_wafv2_web_acl.default.arn

  tags = var.common_tags

  # Wait for certificate validation to complete
  depends_on = [aws_acm_certificate_validation.cert_validation]
}

# --- Route 53 DNS Record for CloudFront Distribution ---
resource "aws_route53_record" "app_dns_record" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false # CloudFront is globally distributed, health checks are typically not needed at DNS level
  }
}

# --- Outputs ---
output "s3_bucket_name" {
  value = try(aws_s3_bucket.website_assets.bucket, "N/A")
  description = "s3_bucket_name"
}

output "s3_bucket_arn" {
  value = try(aws_s3_bucket.website_assets.arn, "N/A")
  description = "s3_bucket_arn"
}

output "cloudfront_distribution_id" {
  value = try(aws_cloudfront_distribution.s3_distribution.id, "N/A")
  description = "cloudfront_distribution_id"
}

output "cloudfront_domain_name" {
  value = try(aws_cloudfront_distribution.s3_distribution.domain_name, "N/A")
  description = "cloudfront_domain_name"
}

output "application_url" {
  description = "URL of the deployed application."
  value       = "https://${var.domain_name}"
}

output "acm_certificate_arn" {
  value = try(aws_acm_certificate.app_certificate.arn, "N/A")
  description = "acm_certificate_arn"
}

output "waf_web_acl_arn" {
  value = try(aws_wafv2_web_acl.default.arn, "N/A")
  description = "waf_web_acl_arn"
}