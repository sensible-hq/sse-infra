resource "aws_security_group" "instance_sg" {
  name   = "sensible-sg-vpc"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = var.application_port
    to_port   = var.application_port
    protocol  = "tcp"
    self      = true
  }
  ingress {
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  ingress {
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sensible-sg-vpc"
  }
}
