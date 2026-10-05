terraform {
  backend "s3" {
    bucket       = "enterprise-tfstate-prod-useast1-001"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
