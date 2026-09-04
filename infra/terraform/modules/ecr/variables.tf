variable "repository_name" {
  type        = string
  description = "Unique name identifier for the ECR repository."
}

variable "environment" {
  type        = string
  description = "Deployment environment lifecycle stage."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Metadata tags applied to the container registry."
}
