resource "aws_appautoscaling_target" "ecs" {
  count = var.enabled_auto_scaling ? 1 : 0
  max_capacity       = var.autoscaling_capacity.max
  min_capacity       = var.autoscaling_capacity.min
  resource_id        = "service/${aws_ecs_cluster.server.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_ram" {
  count = var.enabled_auto_scaling ? 1 : 0
  name               = "scaling_based_on_ram"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.autoscaling_based_on_ram_target_value
  }
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  count = var.enabled_auto_scaling ? 1 : 0
  name               = "scaling_based_on_cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.autoscaling_based_on_cpu_target_value
  }
}

