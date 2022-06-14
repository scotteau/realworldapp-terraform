#################################################################################
## alb
#################################################################################
resource "aws_alb_target_group" "ecs" {
  name        = "${local.prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = local.default_tags
}

resource "aws_lb" "alb" {
  name               = "${local.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnets
  tags = local.default_tags
}




resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs.arn
  }
}

resource "aws_lb_listener" "redirect-to-https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# route53 A record for alb
data "aws_route53_zone" "domain" {
  name = var.domain_name
}

resource "aws_route53_record" "api" {
  name    = "${var.project_name}.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.domain.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
  }
}
