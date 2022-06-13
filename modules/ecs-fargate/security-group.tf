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
