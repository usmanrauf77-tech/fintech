variable "blocked_ips" {
  description = "List of malicious IP addresses to block"
  type        = list(string)
  default     = ["203.0.113.10/32", "198.51.100.25/32"]
}

variable "project" {
    type = string
}

variable "environment" {
    type = string
}

variable "region" {
    type = string
}

variable "domain_name" {
    type = string
}

variable "subdomain" {
    type = string
}

variable "source_repo_url" {
    type = string
}

variable "branch" {
    type    = string
    default = "main"
}

variable "hosted_zone_id" {
    type = string
}

variable "secret_arn" {
    type = string
}

variable "auto_scaling_arn" {
    type = string
}

variable "ecr_repository_url" {
    type = string
}

variable "access_role_arn" {
    type = string
}

variable "github_connection_arn" {
    type = string
}

variable "artifact_bucket" {
    type = string
}

variable "github_repo" {
    type = string
}

variable "codepipeline_role_arn" {
    type = string
}

variable "codebuild_role_arn" {
    type = string
}

variable "github_branch" {
    type = string
}
