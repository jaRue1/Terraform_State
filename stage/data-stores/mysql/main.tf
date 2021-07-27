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
# creates a database in RDS
resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running-jaruejohnson"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "example_database"
  username            = "admin"
  password            = "password"
   skip_final_snapshot  = true
}
#store its state in the S3 bucket you created 
terraform {
  backend "s3" {
    
    bucket         = "terraform-state-rue-johnson-example"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-east-1"
    
    dynamodb_table = "terraform-locks-table"
    encrypt        = true
  }
}