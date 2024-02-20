resource "aws_security_group" "instance_sg" {
  name   = "${var.stage}-instance-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.stage}-instance-sg"
  }
}

resource "aws_security_group_rule" "instance_sg_rule_1" {
  type              = "ingress"
  from_port         = var.application_port
  to_port           = var.application_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.instance_sg.id
}

resource "aws_security_group_rule" "instance_sg_rule_2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance_sg.id
}
