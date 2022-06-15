module "vpc" {
  source = "../../modules/networking"

  region       = local.region
  project_name = local.project_name
  environment  = local.environment

  cidr_block = "10.0.0.0/16"
  public     = ["10.0.101.0/24", "10.0.102.0/24"]
  private    = ["10.0.11.0/24", "10.0.12.0/24"]
}
