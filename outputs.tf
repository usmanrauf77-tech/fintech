output "apprunner_service_url" {
  description = "Public URL of the App Runner service"
  value       = module.apprunner.service_url
}

output "cloudfront_distribution" {
  description = "CloudFront domain name"
  value       = module.cloudfront.domain_name
}

output "waf_acl_arn" {
  description = "WAF ACL ARN"
  value       = module.waf.waf_arn
}
output "waf_logs_bucket_arn" {
  value = aws_s3_bucket.waf_logs.arn
  description = "S3 bucket ARN for WAF logs"
}