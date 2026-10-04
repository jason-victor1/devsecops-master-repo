variable "cluster_name" {
  description = "Name of the target EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "prod"
}

variable "namespace" {
  description = "Kubernetes namespace hosting the admission controller"
  type        = string
  default     = "kyverno"
}

variable "service_account" {
  description = "Kubernetes ServiceAccount name for Kyverno"
  type        = string
  default     = "kyverno-admission-controller"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
