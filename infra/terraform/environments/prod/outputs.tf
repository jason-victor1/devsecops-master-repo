output "vpc_id" {
  description = "The ID of the provisioned VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "The URL of the ECR container repository"
  value       = module.ecr.repository_url
}

output "github_oidc_role_arn" {
  description = "IAM Role ARN for GitHub Actions keyless container signing & push"
  value       = module.github_oidc.role_arn
}

output "s3_bucket_arn" {
  description = "ARN of the production S3 ingestion bucket"
  value       = module.s3_storage.bucket_arn
}

output "eks_cluster_name" {
  description = "Name of the production EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "kyverno_pod_identity_role_arn" {
  description = "IAM Role ARN mapped to Kyverno via EKS Pod Identity"
  value       = module.pod_identity.kyverno_role_arn
}
