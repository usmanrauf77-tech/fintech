variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "blocked_ips" {
  description = "List of malicious IPs to block"
  type        = list(string)
  default     = []
}
