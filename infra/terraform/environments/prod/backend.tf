terraform {
  backend "s3" {
    bucket         = "enterprise-tfstate-prod-useast1-001"
    key            = "event-ingestion/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "enterprise-tflocks-prod"
    encrypt        = true
  }
}
