# Terraform Backend Configuration

# Create S3 bucket and DynamoDB table for state management:
# 
# aws s3api create-bucket --bucket <your-unique-bucket-name>-terraform-state --region us-east-1
# aws dynamodb create-table --table-name terraform-state-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST

terraform {
  backend "s3" {
    bucket         = "your-bucket-name-terraform-state"
    key            = "aws-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
