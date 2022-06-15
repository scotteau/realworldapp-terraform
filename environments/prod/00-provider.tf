provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "my-terraform-shared-state"
    key    = "realworldapp/prod/state/terraform.tfstate"
    region = "ap-southeast-2"

    dynamodb_table = "terraform-shared-state-locks"
    encrypt        = true
  }
}
