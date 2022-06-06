################################################################################
# ecs-fargate
################################################################################
locals {
  db_url = aws_ssm_parameter.url.value
}

variable "ecr_repository_url" {
  description = "The repository url of preferred docker image within ECR"
  type        = string
}

resource "aws_ecs_cluster" "server" {
  name = "${local.prefix}-cluster"
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "realworldapp-server"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  ephemeral_storage {
    size_in_gib = 30
  }

  container_definitions = templatefile(
    "${path.root}/templates/container_definition.json.tftpl",
    {
      name         = "${var.project_name}-server"
      image        = "${var.ecr_repository_url}:latest"
      DATABASE_URL = local.db_url
      PORT         = 3000
      region       = "ap-southeast-2"
  })

  tags = merge(local.default_tags, {
    Name = "${local.prefix}-task-definition"
  })
}

#resource "aws_ecs_service" "server" {
#  name            = "${local.prefix}-server"
#  cluster         = aws_ecs_cluster.server.id
#  task_definition = aws_ecs_task_definition.server.arn
#  desired_count   = 1
#  iam_role        = aws_iam_role.ecs_task_role.arn
#
#  launch_type = "FARGATE"
#
#  load_balancer {
#    target_group_arn = aws_lb_target_group.target-group.arn
#    container_name   = "server"
#    container_port   = 3000
#  }
#
#  network_configuration {
#    subnets         = [aws_subnet.private[0].id]
#    security_groups = [aws_security_group.ecs-fargate.id]
#  }
#}
