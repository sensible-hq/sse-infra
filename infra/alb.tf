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
}

resource "aws_security_group" "sg_alb" {
  name = "sensible-sg-alb"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.ec2.id
  port             = 8000
}