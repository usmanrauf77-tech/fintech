variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev/stage/prod)"
}

variable "artifact_bucket" {
  type        = string
  description = "S3 bucket for pipeline artifacts"
}

variable "github_connection_arn" {
  type        = string
  description = "CodeStar connection ARN for GitHub"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo in owner/name format"
}

variable "github_branch" {
  type        = string
  description = "Branch to build"
}

variable "codebuild_role_arn" {
  type        = string
  description = "IAM role ARN for CodeBuild"
}

variable "codepipeline_role_arn" {
  type        = string
  description = "IAM role ARN for CodePipeline"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL"
}

variable "apprunner_service_arn" {
  type        = string
  description = "App Runner service ARN"
}
