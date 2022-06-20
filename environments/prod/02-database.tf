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
  ecs_sg_id            = module.ecs-fargate.ecs_sg_id
  db_name              = local.project_name
  enable_direct_access = true
  your_cidr            = var.your_cidr
  internet_gateway_id  = module.vpc.internet_gateway_id
}
