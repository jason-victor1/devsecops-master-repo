output "kyverno_role_arn" {
  description = "IAM Role ARN mapped to Kyverno ServiceAccount"
  value       = aws_iam_role.kyverno_ecr.arn
}

output "association_id" {
  description = "EKS Pod Identity association ID"
  value       = aws_eks_pod_identity_association.kyverno.id
}
