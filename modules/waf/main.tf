# S3 bucket for WAF logs
resource "aws_s3_bucket" "waf_logs" {
    bucket_prefix = "aws-waf-logs-${var.project}-${var.environment}-"

    tags = {
        Project = var.project
    }
}

# Server-side encryption for logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
    bucket = aws_s3_bucket.waf_logs.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# Block public access for logs bucket
resource "aws_s3_bucket_public_access_block" "waf_logs" {
    bucket = aws_s3_bucket.waf_logs.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# S3 bucket policy for WAF logs
resource "aws_s3_bucket_policy" "waf_logs" {
    bucket = aws_s3_bucket.waf_logs.id
    policy = data.aws_iam_policy_document.waf_logs.json
}

# IAM policy document for WAF log delivery
data "aws_iam_policy_document" "waf_logs" {
    statement {
        sid = "AWSLogDeliveryWrite"
        principals {
            type        = "Service"
            identifiers = ["delivery.logs.amazonaws.com"]
        }
        actions   = ["s3:PutObject"]
        resources = ["${aws_s3_bucket.waf_logs.arn}/AWSLogs/*"]
    }

    statement {
        sid = "AWSLogDeliveryAclCheck"
        principals {
            type        = "Service"
            identifiers = ["delivery.logs.amazonaws.com"]
        }
        actions   = ["s3:GetBucketAcl"]
        resources = [aws_s3_bucket.waf_logs.arn]
    }
}

# WAF IP set for blocking malicious IPs
resource "aws_wafv2_ip_set" "malicious_ips" {
    name              = "${var.project}-${var.environment}-malicious-ips"
    description       = "IP addresses blocked due to malicious activity"
    scope             = "CLOUDFRONT"
    ip_address_version = "IPV4"
    addresses         = var.blocked_ips

    tags = {
        Project     = var.project
        Environment = var.environment
    }
}

# WAF Web ACL for CloudFront
resource "aws_wafv2_web_acl" "this" {
    name        = "${var.project}-${var.environment}-web-acl"
    description = "Web ACL for CloudFront distribution"
    scope       = "CLOUDFRONT"

    default_action {
        allow {}
    }

    rule {
        name     = "BlockMaliciousIPs"
        priority = 1

        action {
            block {}
        }

        statement {
            ip_set_reference_statement {
                arn = aws_wafv2_ip_set.malicious_ips.arn
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "${var.project}-${var.environment}-block-ips"
            sampled_requests_enabled   = true
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.project}-${var.environment}-web-acl"
        sampled_requests_enabled   = true
    }

    tags = {
        Project     = var.project
        Environment = var.environment
    }
}

# WAF logging configuration
resource "aws_wafv2_web_acl_logging_configuration" "this" {
    resource_arn = aws_wafv2_web_acl.this.arn

    log_destination_configs = [aws_s3_bucket.waf_logs.arn]

 
}

