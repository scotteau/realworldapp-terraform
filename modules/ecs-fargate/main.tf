################################################################################
# ecs-fargate
################################################################################
resource "aws_ecs_cluster" "server" {
  name = "${local.prefix}-cluster"
}

resource "aws_ecs_task_definition" "backend" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    cpu_architecture        = var.cpu_architecture
    operating_system_family = var.operating_system_family
  }
  ephemeral_storage {
    size_in_gib = var.storage_size
  }

  container_definitions = var.container_definition

  tags = merge(local.default_tags, {
    Name = "${local.prefix}-task-definition"
  })
}

resource "aws_ecs_service" "service" {

  name            = "${local.prefix}-ecs-service"
  cluster         = aws_ecs_cluster.server.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  load_balancer {
    container_name   = var.container_name
    container_port   = var.container_port
    target_group_arn = var.target_group_arn
  }

  network_configuration {
    subnets          = var.subnets_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  tags = merge(local.default_tags, { Name = "${local.prefix}-service" })
}