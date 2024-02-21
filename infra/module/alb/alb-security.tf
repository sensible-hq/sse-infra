resource "aws_security_group" "sg" {
  name   = "${var.stage}-alb-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.stage}-alb-sg"
  }
}

resource "aws_security_group_rule" "rule_1" {
  type              = "ingress"
  from_port         = var.load_balancer_port
  to_port           = var.load_balancer_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "rule_2" {
  type              = "egress"
  from_port         = var.application_port
  to_port           = var.application_port
  protocol          = "tcp"
  cidr_blocks       = var.alb_egress_cidr_blocks
  security_group_id = aws_security_group.sg.id
}
