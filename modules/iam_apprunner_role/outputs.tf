output "apprunner_access_role_arn" {
  description = "IAM role ARN for App Runner to pull from ECR, read secrets, and write logs"
  value       = aws_iam_role.apprunner_access.arn
}
