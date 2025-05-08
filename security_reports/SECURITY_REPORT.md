# Security Scan Report

## Summary
- **Total Issues Found**: 105
- **TFSec Issues**: 0
- **Checkov Issues**: 105

## Detailed Reports
- [TFSec Report](tfsec_report.md)
- [Checkov Report](checkov_report.txt)

## Recommendations
### General Security Recommendations
- Encrypt sensitive data at rest and in transit
- Use IAM roles with least privilege access
- Enable logging and monitoring for all resources
- Implement network security groups with restrictive rules
- Use secure defaults for all resources

### Common Issues to Fix
#### Checkov Findings
- CKV2_AWS_11: "Ensure VPC flow logging is enabled in all VPCs"
- CKV2_AWS_12: "Ensure the default security group of every VPC restricts all traffic"
- CKV2_AWS_20: "Ensure that ALB redirects HTTP requests into HTTPS ones"
- CKV2_AWS_27: "Ensure Postgres RDS as aws_rds_cluster has Query Logging enabled"
- CKV2_AWS_28: "Ensure public facing ALB are protected by WAF"
- CKV2_AWS_32: "Ensure CloudFront distribution has a response headers policy attached"
- CKV2_AWS_35: "AWS NAT Gateways should be utilized for the default route"
- CKV2_AWS_42: "Ensure AWS CloudFront distribution uses custom SSL certificate"
- CKV2_AWS_44: "Ensure AWS route table with VPC peering does not contain routes overly permissive to all traffic"
- CKV2_AWS_46: "Ensure AWS CloudFront Distribution with S3 have Origin Access set to enabled"
