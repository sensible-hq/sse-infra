# resource "aws_s3_object" "folder1" {
#   bucket = "datadeft-tf-dev"
#   key    = "test"
#   source = "/dev/null"
# }

resource "aws_lb" "alb" {
  name               = "alb-test"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]
  idle_timeout       = 1800
}

resource "aws_security_group" "sg_alb" {
  name   = "sensible-sg-alb"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sensible-sg-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg-test"
  port     = 8000
  protocol = "HTTP"
  # protocol_version = "HTTP2"
  vpc_id = aws_vpc.vpc.id

  # stickiness {
  #   enabled         = false
  #   type            = "lb_cookie"
  #   cookie_duration = 1800
  # }
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.ec2[count.index].id
  port             = 8000
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "8000"
  protocol          = "HTTP"

  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn

    # forward {
    #   target_group {
    #     arn = aws_lb_target_group.alb_tg.arn
    #   }
    #   stickiness {
    #     enabled  = false
    #     duration = 1800
    #   }
    # }
  }
}
