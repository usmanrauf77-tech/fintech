resource "aws_route53_record" "this" {
  zone_id = var.hosted_zone_id
  name    = var.subdomain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
