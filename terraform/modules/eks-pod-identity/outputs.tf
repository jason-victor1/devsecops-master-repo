output "role_arn" {
  description = "ARN of the Kyverno Pod Identity IAM role"
  value       = aws_iam_role.kyverno_pod_identity.arn
}

output "association_id" {
  description = "ID of the EKS Pod Identity association"
  value       = aws_eks_pod_identity_association.kyverno.id
}
