variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repo URL where the container image is stored"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the secret from AWS Secrets Manager"
  type        = string
}

variable "access_role_arn" {
  description = "IAM role ARN allowing App Runner to pull images from ECR and read secrets"
  type        = string
}

variable "auto_scaling_arn" {
  description = "App Runner Auto Scaling Configuration ARN"
  type        = string
}

variable "container_port" {
  description = "Container port exposed by the service"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU for App Runner instance"
  type        = string
  default     = "1024"
}

variable "memory" {
  description = "Memory for App Runner instance"
  type        = string
  default     = "2048"
}
