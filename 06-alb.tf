################################################################################
# alb
################################################################################

resource "aws_lb" "load-balancer" {
  name               = "${local.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = tolist(aws_subnet.public[*].id)


  tags = local.default_tags
}

# alb - target group
resource "aws_lb_target_group" "target-group" {
  name        = "${local.prefix}-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

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


# alb - listener
resource "aws_lb_listener" "https-listener" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

# alb - listener - HTTP
resource "aws_lb_listener" "redirect-to-https" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      path        = "HTTPS://#{host}:443/#{path}?#{query}"
    }
  }
}
