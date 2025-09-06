variable "apprunner_domain_name" {
  type        = string
  description = "Default domain name of App Runner service"
}

variable "acm_cert_arn" {
  type        = string
  description = "ACM certificate ARN for custom domain"
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}
variable "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL to associate with the CloudFront distribution."
  type        = string
  default     = ""
}