
# [tfsec] Results
## Failed: 7 issue(s)
| # | ID | Severity | Title | Location | Description |
|---|----|----------|-------|----------|-------------|
| 1 | `aws-s3-enable-bucket-encryption` | *HIGH* | _Unencrypted S3 bucket._ | `terraform/main.tf:79-86` | Bucket does not have encryption enabled |
| 2 | `aws-s3-enable-bucket-encryption` | *HIGH* | _Unencrypted S3 bucket._ | `terraform/main.tf:54-62` | Bucket does not have encryption enabled |
| 3 | `aws-s3-enable-bucket-logging` | *MEDIUM* | _S3 Bucket does not have logging enabled._ | `terraform/main.tf:79-86` | Bucket does not have logging enabled |
| 4 | `aws-s3-enable-bucket-logging` | *MEDIUM* | _S3 Bucket does not have logging enabled._ | `terraform/main.tf:54-62` | Bucket does not have logging enabled |
| 5 | `aws-s3-enable-versioning` | *MEDIUM* | _S3 Data should be versioned_ | `terraform/main.tf:79-86` | Bucket does not have versioning enabled |
| 6 | `aws-s3-encryption-customer-key` | *HIGH* | _S3 encryption should use Customer Managed Keys_ | `terraform/main.tf:79-86` | Bucket does not encrypt data with a customer managed key. |
| 7 | `aws-s3-encryption-customer-key` | *HIGH* | _S3 encryption should use Customer Managed Keys_ | `terraform/main.tf:54-62` | Bucket does not encrypt data with a customer managed key. |

