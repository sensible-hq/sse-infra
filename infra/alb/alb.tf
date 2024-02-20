resource "aws_lb" "alb" {
  name                       = "${var.stage}-alb"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.sg.id]
  subnets                    = var.subnet_ids
  idle_timeout               = var.alb_idle_timeout
  enable_deletion_protection = var.alb_deletion_protection
  enable_http2               = var.alb_enable_http2
  internal                   = false
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.load_balancer_port
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
