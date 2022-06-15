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

  family = "${local.project_name}-server"
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