data "terraform_remote_state" "db" {
  backend = "s3"
  config = {

    bucket    = "terraform-state-rue-johnson-example"
    key       = "stage/data-stores/mysql/terraform.tfstate"
    region    = "us-east-1"

  }
}
locals {
    db_address="${data.terraform_remote_state.db.outputs.address}"
    db_port="${data.terraform_remote_state.db.outputs.port}"
}
