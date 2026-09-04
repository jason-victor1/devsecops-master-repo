variable "github_org" {
  type        = string
  description = "GitHub organization or account name."
}

variable "github_repo" {
  type        = string
  description = "Target GitHub repository name."
}

variable "github_branch" {
  type        = string
  default     = "main"
  description = "Git branch authorized for assume role federation."
}

variable "ecr_repository_arn" {
  type        = string
  description = "ARN of the ECR repository allowing push permissions."
}

variable "role_name" {
  type        = string
  description = "Name of the IAM role to create for GitHub Actions."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags."
}
