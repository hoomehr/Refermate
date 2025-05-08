
# [tfsec] Results
## Failed: 39 issue(s)
| # | ID | Severity | Title | Location | Description |
|---|----|----------|-------|----------|-------------|
| 1 | `aws-cloudfront-enable-logging` | *MEDIUM* | _Cloudfront distribution should have Access Logging configured_ | `terraform/main.tf:403-458` | Distribution does not have logging enabled. |
| 2 | `aws-cloudfront-enable-waf` | *HIGH* | _CloudFront distribution does not have a WAF in front._ | `terraform/main.tf:403-458` | Distribution does not utilise a WAF. |
| 3 | `aws-cloudfront-use-secure-tls-policy` | *HIGH* | _CloudFront distribution uses outdated SSL/TLS protocols._ | `terraform/main.tf:451-457` | Distribution allows unencrypted communications. |
| 4 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:177-182` | Security group rule does not have a description. |
| 5 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:170-175` | Security group rule does not have a description. |
| 6 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:153-158` | Security group rule does not have a description. |
| 7 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:146-151` | Security group rule does not have a description. |
| 8 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:139-144` | Security group rule does not have a description. |
| 9 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:132-137` | Security group rule does not have a description. |
| 10 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:115-120` | Security group rule does not have a description. |
| 11 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:108-113` | Security group rule does not have a description. |
| 12 | `aws-ec2-add-description-to-security-group-rule` | *LOW* | _Missing description for security group rule._ | `terraform/main.tf:101-106` | Security group rule does not have a description. |
| 13 | `aws-ec2-enforce-launch-config-http-token-imds` | *HIGH* | _aws_instance should activate session tokens for Instance Metadata Service._ | `terraform/main.tf:262-305` | Launch template does not require IMDS access to require a token |
| 14 | `aws-ec2-no-public-egress-sgr` | *CRITICAL* | _An egress security group rule allows traffic to /0._ | `terraform/main.tf:181` | Security group rule allows egress to multiple public internet addresses. |
| 15 | `aws-ec2-no-public-egress-sgr` | *CRITICAL* | _An egress security group rule allows traffic to /0._ | `terraform/main.tf:157` | Security group rule allows egress to multiple public internet addresses. |
| 16 | `aws-ec2-no-public-egress-sgr` | *CRITICAL* | _An egress security group rule allows traffic to /0._ | `terraform/main.tf:119` | Security group rule allows egress to multiple public internet addresses. |
| 17 | `aws-ec2-no-public-ingress-sgr` | *CRITICAL* | _An ingress security group rule allows traffic from /0._ | `terraform/main.tf:112` | Security group rule allows ingress from public internet. |
| 18 | `aws-ec2-no-public-ingress-sgr` | *CRITICAL* | _An ingress security group rule allows traffic from /0._ | `terraform/main.tf:105` | Security group rule allows ingress from public internet. |
| 19 | `aws-ec2-no-public-ip-subnet` | *HIGH* | _Instances in a subnet should not receive a public IP address by default._ | `terraform/main.tf:40` | Subnet associates public IP address. |
| 20 | `aws-ec2-no-public-ip-subnet` | *HIGH* | _Instances in a subnet should not receive a public IP address by default._ | `terraform/main.tf:30` | Subnet associates public IP address. |
| 21 | `aws-ec2-require-vpc-flow-logs-for-all-vpcs` | *MEDIUM* | _VPC Flow Logs is a feature that enables you to capture information about the IP traffic going to and from network interfaces in your VPC. After you've created a flow log, you can view and retrieve its data in Amazon CloudWatch Logs. It is recommended that VPC Flow Logs be enabled for packet "Rejects" for VPCs._ | `terraform/main.tf:19-24` | VPC Flow Logs is not enabled for VPC  |
| 22 | `aws-elb-alb-not-public` | *HIGH* | _Load balancer is exposed to the internet._ | `terraform/main.tf:194` | Load balancer is exposed publicly. |
| 23 | `aws-elb-drop-invalid-headers` | *HIGH* | _Load balancers should drop invalid headers_ | `terraform/main.tf:192-204` | Application load balancer is not set to drop invalid headers. |
| 24 | `aws-elb-http-not-used` | *CRITICAL* | _Use of plain HTTP._ | `terraform/main.tf:223` | Listener for application load balancer does not use HTTPS. |
| 25 | `aws-elb-use-secure-tls-policy` | *CRITICAL* | _An outdated SSL policy is in use by a load balancer._ | `terraform/main.tf:235` | Listener uses an outdated TLS policy. |
| 26 | `aws-iam-no-policy-wildcards` | *HIGH* | _IAM policy should avoid use of wildcards and instead apply the principle of least privilege_ | `terraform/main.tf:507` | IAM policy document uses sensitive action 'logs:CreateLogGroup' on wildcarded resource 'arn:aws:logs:*:*:*' |
| 27 | `aws-iam-no-policy-wildcards` | *HIGH* | _IAM policy should avoid use of wildcards and instead apply the principle of least privilege_ | `terraform/main.tf:507` | IAM policy document uses sensitive action 's3:GetObject' on wildcarded resource '74a69141-e021-46a4-84a6-4fcd201ed846' |
| 28 | `aws-iam-no-policy-wildcards` | *HIGH* | _IAM policy should avoid use of wildcards and instead apply the principle of least privilege_ | `terraform/main.tf:507` | IAM policy document uses sensitive action 'logs:CreateLogGroup' on wildcarded resource 'arn:aws:logs:*:*:*' |
| 29 | `aws-iam-no-policy-wildcards` | *HIGH* | _IAM policy should avoid use of wildcards and instead apply the principle of least privilege_ | `terraform/main.tf:507` | IAM policy document uses sensitive action 's3:GetObject' on wildcarded resource '74a69141-e021-46a4-84a6-4fcd201ed846' |
| 30 | `aws-rds-enable-performance-insights` | *LOW* | _Enable Performance Insights to detect potential problems_ | `terraform/main.tf:366-373` | Instance does not have performance insights enabled. |
| 31 | `aws-rds-enable-performance-insights` | *LOW* | _Enable Performance Insights to detect potential problems_ | `terraform/main.tf:366-373` | Instance does not have performance insights enabled. |
| 32 | `aws-rds-encrypt-cluster-storage-data` | *HIGH* | _There is no encryption specified or encryption is disabled on the RDS Cluster._ | `terraform/main.tf:343-364` | Cluster does not have storage encryption enabled. |
| 33 | `aws-s3-block-public-acls` | *HIGH* | _S3 Access block should block public ACL_ | `terraform/main.tf:377-398` | No public access block so not blocking public acls |
| 34 | `aws-s3-block-public-policy` | *HIGH* | _S3 Access block should block public policy_ | `terraform/main.tf:377-398` | No public access block so not blocking public policies |
| 35 | `aws-s3-enable-bucket-logging` | *MEDIUM* | _S3 Bucket does not have logging enabled._ | `terraform/main.tf:377-398` | Bucket does not have logging enabled |
| 36 | `aws-s3-encryption-customer-key` | *HIGH* | _S3 encryption should use Customer Managed Keys_ | `terraform/main.tf:377-398` | Bucket does not encrypt data with a customer managed key. |
| 37 | `aws-s3-ignore-public-acls` | *HIGH* | _S3 Access Block should Ignore Public Acl_ | `terraform/main.tf:377-398` | No public access block so not ignoring public acls |
| 38 | `aws-s3-no-public-buckets` | *HIGH* | _S3 Access block should restrict public bucket to limit access_ | `terraform/main.tf:377-398` | No public access block so not restricting public buckets |
| 39 | `aws-s3-specify-public-access-block` | *LOW* | _S3 buckets should each define an aws_s3_bucket_public_access_block_ | `terraform/main.tf:377-398` | Bucket does not have a corresponding public access block. |

