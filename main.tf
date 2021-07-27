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

    # set key value to workspaces-example/terraform.tfstate: 
    key = "workspaces-example/terraform.tfstate"
    
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
# my state file in s3 Bucket
# https://terraform-state-rue-johnson-example.s3.us-east-1.amazonaws.com/global/s3/terraform.tfstate?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEsaCXVzLWVhc3QtMSJIMEYCIQC91LcNymIjbjWIF2Kh4Fp7NSmTX7ZDbS2uylGkgwmqawIhANAsjZdLL0b1zhRnq0obPTBvaRGIDHQeogPnYnwjygdxKo0DCFQQABoMMDk3MDI5Mzc5Mzg4IgzAFJdbvGkgbkOi4acq6gJMW30MRS0zGps6a9wx5xBGcdKiItWiu5YeMHelzHM00MbJRe7Le%2FxBY0P%2B9UyI620%2BufMOA4UG%2FttmMR0OMb%2BPPkT8n6BZb68SP6%2BMk6d4ky%2BR37dFLiZReiGaSvKGX0e1kVMdOi%2Bx2zdfuvwWLEDRotCUc%2B3iANf7UEr%2BzPve8THrpbvTqqLuo%2Bqh2%2FVLf8yr8%2Bg3q4b%2BrSwxfy2KLGp7jo19gQxPPB4qfQpLsjPsf1YHvwgaqeDKkIfjy3NguJ3UqKyVngLHEPqSMmXpZRNE53yqkFTrC1XXy%2FZohdtzT9GOhyybkWclav7QlONL0S%2BeL%2Flw3vrd6UpQUDfokag2sJnzQMVDy4n%2BqAHYSOp9cWU2YB8qp9%2BP21%2FAPcvb%2FnaVVR%2F26OIOAbykue%2FlYZ%2FbNGUwn4VLTtaIVzdfB2Z8Qpqw9%2Bp96SrGI%2BA8hVEasIe9brGdupdSAHUFSuMPBwEOGJIi9umjyqX7%2FTCi6f2HBjqyAqEdEdxuPt3YjtSAkcJZQYvSlNHNJE09TJSWMjcp8RjbNOne37YkrA04JsMBLroocKzGJeA0dJcQwEFQ%2Byx3rGgrbihtnLBgYsrix%2BAi%2BezFOP7hN6RcARKPYwDSYFzCOTLzYz7uINSVfAUpIXWNrc7kKeTGJXINoBT6pIXokNuH9Emysvhxz%2BbnT1w3k66kKGtYEtbUCX5YggLpqhlfedM%2F8qvSmhxXj%2FhXZeHkH%2F29frqCX%2F%2FvIsBCQkSJfkVHYDzml9g6mGtbXu1MjxxNRWoxe5OV9ymP%2BkhF0mE9SgRLAGheUr0UVgBEivNS%2FrKR%2F9KDdR3Vm2T8mHJyZwUO8A6CHBsWMNnb849ozso0iZmM8nEl%2BiG6p9V0%2FCZqrHte2%2F7uEP44OIL2nUDX2f2xYQ3%2Fjg%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20210727T033709Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIARNF3G2U6I46EIXUL%2F20210727%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=9bfc0a3eb78d41171e74050a592054ced7b3a99f94ca23c1e941cd37c728101b

# -------------- Isolation via workspaces ----------------
# Create ec2 instance 
resource "aws_instance" "example" {
  ami           = "ami-0747bdcabd34c712a"
  instance_type = "t2.micro"
}
