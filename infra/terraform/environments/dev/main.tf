module "s3_storage" {
  source      = "../../modules/s3_storage"
  bucket_name = "enterprise-event-ingest-raw-dev-001"
  environment = "dev"
  tags = {
    CostCenter = "Engineering"
  }
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "event-ingestion-api-dev"
  environment     = "dev"
}

module "github_oidc" {
  source             = "../../modules/github_oidc"
  github_org         = var.github_org
  github_repo        = var.github_repo
  github_branch      = "main"
  ecr_repository_arn = module.ecr.repository_arn
  role_name          = "github-actions-dev-ingestion-role"
}
