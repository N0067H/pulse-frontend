variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "prod"
}

variable "backend_url" {
  type        = string
  description = "EC2 backend public DNS (e.g. ec2-xx-xx-xx-xx.compute-1.amazonaws.com)"
}

variable "backend_port" {
  type        = number
  description = "Backend HTTP port"
  default     = 8080
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in 'owner/repo' format (e.g. N0067H/pulse-frontend)"
}
