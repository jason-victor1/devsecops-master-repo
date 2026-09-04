output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "github_oidc_role_arn" {
  value = module.github_oidc.role_arn
}

output "s3_bucket_arn" {
  value = module.s3_storage.bucket_arn
}
