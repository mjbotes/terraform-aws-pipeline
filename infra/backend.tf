# S3 backend for remote state management

terraform {
  backend "s3" {
    bucket         = "mjbotes-terraform-state-2024"
    key            = "aws-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}