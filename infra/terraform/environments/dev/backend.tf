terraform {
  backend "s3" {
    bucket         = "enterprise-tfstate-dev-useast1-001"
    key            = "event-ingestion/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "enterprise-tflocks-dev"
    encrypt        = true
  }
}
