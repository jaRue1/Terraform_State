terraform {
  required_providers{
    aws = {
      source = "hashicorp/aws"
      version = "~>3.5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# create an S3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-rue-johnson-example"
  # Enable versioning
  versioning {
    enabled = true
  }
  # Enable encryption by default
  server_side_encryption_configuration {
    rule{
      apply_server_side_encryption_by_default{
        sse_algorithm = "AES256"
      }
    }
  }
}

# create an DynamoDB Table
resource "aws_dynamodb_table" "terraform_state_locks" {
  name = "terraform-locks-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3"{
    bucket = "terraform-state-rue-johnson-example"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-locks-table"
    encrypt = true
  }
}

# Terraform will automatically pull the latest state from this S3 bucket before running a command, and automatically push the latest state to the S3 bucket after running a command. 
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_state_locks.name
  description = "The name of the DynamoDB table"
}