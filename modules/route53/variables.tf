variable "hosted_zone_id" {
  description = "ID of the hosted zone in Route53"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain to create (e.g., verify.paynest.com)"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution (e.g., dxxxxx.cloudfront.net)"
  type        = string
}

variable "cloudfront_zone_id" {
  description = "CloudFront hosted zone ID (always Z2FDTNDATAQYW2)"
  type        = string
  default     = "Z2FDTNDATAQYW2" # AWS fixed zone ID for CloudFront
}
