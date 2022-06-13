################################################################################
# Security Group
################################################################################
#variable "database_ingress_ports" {
#  description = "Ports opened for database"
#  type        = list(number)
#}
#
#variable "ecs_ingress_ports" {
#  description = "Ports opened for ECS"
#  type        = list(number)
#}
#
#variable "alb_ingress_ports" {
#  description = "Ports opened for ALB"
#  type        = list(number)
#}



# Security Group - Database
resource "aws_security_group_rule" "ecs_access" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.rds_aurora.security_group_id
  source_security_group_id = aws_security_group.ecs.id
}

################################################################################
# Special ingress rule for initial db seeding access
################################################################################
#variable "your_cidr" {
#  description = "Your CIDR block for initial db seeding access"
#  type        = list(string)
#}

#resource "aws_security_group_rule" "initial_access" {
#  description       = "Grant access to local machine to rds sg"
#  type              = "ingress"
#  cidr_blocks       = var.your_cidr
#  from_port         = 5432
#  protocol          = "tcp"
#  security_group_id = module.rds_aurora.security_group_id
#  to_port           = 5432
#}
#
#resource "aws_security_group_rule" "access" {
#  description       = "Grant access to local machine to ecs sg"
#  from_port         = 3000
#  protocol          = "tcp"
#  security_group_id = aws_security_group.ecs.id
#  to_port           = 3000
#  type              = "ingress"
#  cidr_blocks       = var.your_cidr
#}




