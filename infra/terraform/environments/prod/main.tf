module "vpc" {
  source       = "../../modules/vpc"
  vpc_cidr     = "10.0.0.0/16"
  cluster_name = "devsecops-prod-eks"
  environment  = "prod"
  tags = {
    CostCenter = "ProductionWorkloads"
  }
}

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

module "eks" {
  source                               = "../../modules/eks"
  cluster_name                         = "devsecops-prod-eks"
  kubernetes_version                   = "1.31"
  environment                          = "prod"
  private_subnet_ids                   = module.vpc.private_subnet_ids
  cluster_endpoint_public_access       = false
  cluster_endpoint_public_access_cidrs = []
  tags = {
    CostCenter = "ProductionWorkloads"
  }
}

module "pod_identity" {
  source          = "../../modules/pod_identity"
  cluster_name    = module.eks.cluster_name
  environment     = "prod"
  namespace       = "kyverno"
  service_account = "kyverno-admission-controller"
  tags = {
    CostCenter = "ProductionWorkloads"
  }
}
