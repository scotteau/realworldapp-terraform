output "endpoint" {
  value = module.rds_aurora.cluster_endpoint
}

output "connection_string" {
  value = aws_ssm_parameter.url.value
}

output "security_group_id" {
  value = module.rds_aurora.security_group_id
}
