# Outputs for Terraform configuration

output "ec2_instance_ip" {
  description = "IP address of the EC2 instance (if deployed)"
  value       = try(aws_instance.app_server.public_ip, "N/A")
}