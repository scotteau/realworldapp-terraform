
# Security Group - Database
resource "aws_security_group_rule" "ecs_access" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.rds_aurora.security_group_id
  source_security_group_id = var.ecs_sg_id
}

################################################################################
# Special ingress rule for initial db seeding access
################################################################################


resource "aws_security_group_rule" "initial_access" {
  count = var.enable_direct_access ? 1 : 0
  description       = "Grant access to local machine to rds sg"
  type              = "ingress"
  cidr_blocks       = var.your_cidr
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = module.rds_aurora.security_group_id
  to_port           = 5432
}
