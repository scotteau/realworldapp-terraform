data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  description        = "IAM role for ecs task execution role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json

  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}