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

locals {
  project_name = "realworldapp"
  environment  = "prod"
  region       = "ap-southeast-2"
  prefix       = "${local.project_name}-${local.environment}"
}

module "vpc" {
  source = "../../modules/networking"

  region       = local.region
  project_name = local.project_name
  environment  = local.environment

  cidr_block = "10.0.0.0/16"
  public     = ["10.0.101.0/24", "10.0.102.0/24"]
  private    = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "database" {
  source = "../../modules/rds-aurora"

  project_name = local.project_name
  environment  = local.environment

  cluster_name           = "${local.prefix}-db-postgres"
  postgres_version       = "13.4"
  instance_class         = "db.t4g.medium"
  vpc_id                 = module.vpc.vpc_id
  database_ingress_ports = [5432]
  subnet_cidr            = ["10.0.21.0/24", "10.0.22.0/24"]
  cluster_instances = {
    one = {
      publicly_accessible = true
    }
    two = {
      identifier     = "static-member-1"
      instance_class = "db.t4g.medium"
    }
  }
  ecs_sg_id            = ""
  db_name              = local.project_name
  enable_direct_access = true
  your_cidr            = var.your_cidr
  internet_gateway_id  = module.vpc.internet_gateway_id
}

module "static-site-hosting" {
  source = "../../modules/static-website-hosting-s3"

  project_name = local.project_name
  environment  = local.environment
  domain_name  = var.domain_name

  hosting_index_document = "index.html"
  hosting_error_document = "index.html"

  global_certificate_arn = var.global_certificate_arn
}

module "alb" {
  source = "../../modules/alb"

  project_name = local.project_name
  environment = local.environment
  domain_name = var.domain_name

  vpc_id = module.vpc.vpc_id
  alb_ingress_ports = [80, 443]
  certificate_arn = var.certificate_arn
  subnets = module.vpc.public_subnets[*].id
}

module "ecs-fargate" {
  source = "../../modules/ecs-fargate"

  project_name = local.project_name
  environment = local.environment

  vpc_id = module.vpc.vpc_id
  db_url = module.database.connection_string
  subnets_ids = module.vpc.private_subnets[*].id
  ecr_repository_url = var.ecr_repository_url

  enabled_auto_scaling = true
  autoscaling_capacity = {
    max = 10,
    min = 1
  }

  family = "realworldapp-server"
  cpu = "256"
  memory = "512"
  cpu_architecture = "ARM64"
  operating_system_family = "LINUX"
  storage_size = 30
  container_definition = templatefile(
    "${path.root}/templates/container_definition.json.tftpl",
    {
      name         = "${local.project_name}-server"
      image        = "${var.ecr_repository_url}:latest"
      DATABASE_URL = module.database.connection_string
      PORT         = 3000
      region       = "ap-southeast-2"
    })

  desired_count = 1
  container_name = "${local.project_name}-server"
  container_port = 3000

  target_group_arn = module.alb.target_group_arn

  ecs_ingress_ports = [3000]
  ingress_security_groups = [module.alb.alb_security_group_id]
  database_security_group_id = module.database.security_group_id
}