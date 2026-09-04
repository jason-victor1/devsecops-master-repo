module "s3_storage" {
  source      = "../../modules/s3_storage"
  bucket_name = "enterprise-event-ingest-raw-prod-001"
  environment = "prod"
  tags = {
    CostCenter = "ProductionWorkloads"
  }
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "event-ingestion-api-prod"
  environment     = "prod"
}

module "github_oidc" {
  source             = "../../modules/github_oidc"
  github_org         = var.github_org
  github_repo        = var.github_repo
  github_branch      = "main"
  ecr_repository_arn = module.ecr.repository_arn
  role_name          = "github-actions-prod-ingestion-role"
}
