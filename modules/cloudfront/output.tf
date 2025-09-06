output "apprunner_domain_name" {
  description = "Default App Runner service URL"
  value       = aws_apprunner_service.this.service_url
}
