variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
}

variable "secret_arn" {
  description = "Secrets Manager ARN"
  type        = string
}
