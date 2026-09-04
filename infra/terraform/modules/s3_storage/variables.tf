variable "bucket_name" {
  type        = string
  description = "Globally unique name for the S3 bucket."
}

variable "environment" {
  type        = string
  description = "Target deployment environment (e.g., dev, prod)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags for cost allocation and governance."
}
