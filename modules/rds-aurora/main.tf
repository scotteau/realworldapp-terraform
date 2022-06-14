################################################################################
# RDS aurora postgres
################################################################################

module "rds_aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.1.0"


  name           = var.cluster_name
  engine         = "aurora-postgresql"
  engine_version = var.postgres_version
  instance_class = var.instance_class

  instances = var.cluster_instances

  vpc_id                 = var.vpc_id
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
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery", "postgresql"]

  tags = merge(local.default_tags, { Name = "${local.prefix}-aurora-postgres" })
}

resource "random_password" "db_password" {
  length  = 12
  special = false
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



resource "aws_ssm_parameter" "url" {
  name  = "${local.dir}/database_url"
  type  = "SecureString"
  value = "${local.protocol}://${local.username}:${local.password}@${local.host}:${local.port}/${var.db_name}?schema=public"
}


# database subnet
resource "aws_subnet" "database" {
  count                   = length(var.subnet_cidr)
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.default_tags,
    { Name = "${local.prefix}-database-${count.index + 1}" })
}

resource "aws_route_table" "database" {
  vpc_id = var.vpc_id

  tags = merge(local.default_tags, { Name = "${local.prefix}-route-table-database" })
}

data "aws_availability_zones" "available" {}



# Only for first access to seed the database initially
resource "aws_route_table_association" "database" {
  count          = var.enable_direct_access ? length(aws_subnet.database) : 0
  route_table_id = aws_route_table.database.id
  subnet_id      = aws_subnet.database[count.index].id
}

resource "aws_route" "database" {
  count = var.enable_direct_access ? 1 : 0
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}
