provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/networking"

  region = var.region
  project_name = var.project_name
  environment = var.environment

  cidr_block = var.main_vpc_cidr
  public     = var.public_cidr_blocks
  private    = var.private_cidr_blocks
}