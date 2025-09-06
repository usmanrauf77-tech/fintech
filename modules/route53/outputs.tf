output "route53_record_fqdn" {
  description = "The fully qualified domain name of the Route53 record"
  value       = aws_route53_record.alias.fqdn
}
