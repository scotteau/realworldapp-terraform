################################################################################
# RDS aurora postgres
################################################################################

module "rds_aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.1.0"


  name           = "${local.prefix}-db-postgres"
  engine         = "aurora-postgresql"
  engine_version = "13.4"
  instance_class = "db.t4g.medium"

  instances = {
    one = {
      publicly_accessible = true
    }
  }

  vpc_id                 = aws_vpc.main.id
  db_subnet_group_name   = aws_db_subnet_group.aurora_postgres.name
  create_db_subnet_group = false
  create_security_group  = true
  allowed_cidr_blocks    = aws_subnet.database[*].cidr_block


  iam_database_authentication_enabled = true
  master_username                     = aws_ssm_parameter.master_username.value
  master_password                     = aws_ssm_parameter.master_password.value
  create_random_password              = false

  apply_immediately   = true
  skip_final_snapshot = false

  db_parameter_group_name         = aws_db_parameter_group.postgres_13.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.postgres_13.id
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(local.default_tags, { Name = "${local.prefix}-aurora-postgres" })
}

resource "random_password" "db_password" {
  length = 10
}


resource "aws_db_parameter_group" "postgres_13" {
  name        = "${local.prefix}-aurora-db-postgres13-parameter-group"
  family      = "aurora-postgresql13"
  description = "${local.prefix}-aurora-db-postgres13-parameter-group"
  tags        = local.default_tags
}

resource "aws_rds_cluster_parameter_group" "postgres_13" {
  name        = "${local.prefix}-aurora-postgres13-cluster-parameter-group"
  family      = "aurora-postgresql13"
  description = "${local.prefix}-aurora-postgres13-cluster-parameter-group"
  tags        = local.default_tags
}

resource "aws_db_subnet_group" "aurora_postgres" {
  name       = "aurora_postgres"
  subnet_ids = aws_subnet.database[*].id

  tags = local.default_tags
}

# db variables
variable "db_name" {
  type = string
}

variable "master_username" {
  type = string
}


locals {
  dir = "/${var.environment}/${var.project_name}/database"
}

resource "aws_ssm_parameter" "master_password" {
  name  = "${local.dir}/password"
  type  = "SecureString"
  value = random_password.db_password.result
}

resource "aws_ssm_parameter" "master_username" {
  name  = "${local.dir}/username"
  type  = "String"
  value = var.master_username
}

locals {
  protocol = "postgresql"
  username = aws_ssm_parameter.master_username.value
  password = aws_ssm_parameter.master_password.value
  host     = module.rds_aurora.cluster_endpoint
  port     = module.rds_aurora.cluster_port
}

resource "aws_ssm_parameter" "url" {
  name  = "${local.dir}/database_url"
  type  = "SecureString"
  value = "${local.protocol}://${local.username}:${local.password}@${local.host}:${local.port}/${var.db_name}?schema=public"
}

output "endpoint" {
  value = module.rds_aurora.cluster_endpoint
}

