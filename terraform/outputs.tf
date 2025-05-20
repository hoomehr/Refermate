# Outputs for Terraform configuration

output "api_url" {
  description = "URL of the API Gateway (if deployed)"
  value       = try(aws_api_gateway_deployment.api.invoke_url, "N/A")
}

output "lambda_function_name" {
  description = "Name of the Lambda function (if deployed)"
  value       = try(aws_lambda_function.api.function_name, "N/A")
}