# Security Group - ECS
resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ecs_ingress_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = var.ingress_security_groups
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags, { Name = "${local.prefix}-sg-ecs" })
}

resource "aws_security_group_rule" "access" {
  count = var.enabled_direct_access ? 1 : 0
  description       = "Grant access to local machine to ecs sg"
  from_port         = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs.id
  to_port           = 3000
  type              = "ingress"
  cidr_blocks       = var.your_cidr
}

resource "aws_security_group_rule" "ecs_access" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.database_security_group_id
  source_security_group_id = aws_security_group.ecs.id
}
