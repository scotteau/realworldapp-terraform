################################################################################
# ecs_task_execution_role
#################################################################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = file("${path.root}/templates/ecs_task_execution_role.json")
}

################################################################################
# ecs_task_role
#################################################################################
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
  assume_role_policy = file("${path.root}/templates/ecs_task_role_rds_access.json")
}
