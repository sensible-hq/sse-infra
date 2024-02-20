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
