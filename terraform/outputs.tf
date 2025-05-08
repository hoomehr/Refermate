# Outputs for Terraform configuration

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer (if deployed)"
  value       = try(aws_lb.alb.dns_name, "N/A")
}