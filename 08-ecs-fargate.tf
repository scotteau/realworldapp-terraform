################################################################################
# ecs
################################################################################
locals {
  db_url = aws_ssm_parameter.url.value
}

variable "ecr_repository_url" {
  description = "The repository url of preferred docker image within ECR"
  type = string
}


resource "aws_ecs_task_definition" "server" {
  family                   = "service"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  container_definitions = templatefile(
    "${path.root}/json/container_definition.json.tftpl",
    {
      name         = "${local.prefix}-ecs-container"
      image        = "${var.ecr_repository_url}:latest"
      DATABASE_URL = local.db_url
      PORT         = 3000
    }
  )

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_cluster" "server" {
  name = "${local.prefix}-cluster"
}


resource "aws_ecs_service" "server" {
  name            = "${local.prefix}-server"
  cluster         = aws_ecs_cluster.server.id
  task_definition = aws_ecs_task_definition.server.arn
  desired_count   = 1
  iam_role        = aws_iam_role.ecs_task_role.arn

  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group.arn
    container_name   = "server"
    container_port   = 3000
  }

  network_configuration {
    subnets         = [aws_subnet.private[0].id]
    security_groups = [aws_security_group.ecs.id]
  }
}
