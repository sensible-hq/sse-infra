resource "aws_lb_target_group" "tg" {
  name             = "${var.stage}-tg"
  port             = var.application_port
  protocol         = "HTTP"
  protocol_version = var.target_group_protocol_version
  vpc_id           = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
  }
}

resource "aws_lb_target_group_attachment" "attachment" {
  count            = length(var.alb_target_ids)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.alb_target_ids[count.index]
  port             = var.application_port
}
