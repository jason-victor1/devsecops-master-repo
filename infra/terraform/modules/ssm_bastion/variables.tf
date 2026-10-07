variable "environment" {
  description = "Deployment environment (e.g., prod, dev)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID where the bastion EC2 instance resides"
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "Security group ID of the EKS cluster control plane"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
