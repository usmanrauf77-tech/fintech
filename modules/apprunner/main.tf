terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60.0"
    }
  }
}

resource "aws_apprunner_service" "this" {
  service_name = "${var.project}-${var.environment}-doc-verifier"

  source_configuration {
    authentication_configuration {
      access_role_arn = var.access_role_arn
    }

    image_repository {
      image_identifier      = "${var.ecr_repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = var.container_port
        runtime_environment_variables = {
          ENVIRONMENT = var.environment
        }
        runtime_environment_secrets = {
          VERIFIER_API_KEY = var.secret_arn
        }
      }
    }

    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = var.cpu
    memory = var.memory
  }

  auto_scaling_configuration_arn = var.auto_scaling_arn

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

output "service_url" {
  value = aws_apprunner_service.this.service_url
}
