module "alb" {
  source = "./alb"

  stage                         = var.stage
  load_balancer_port            = var.load_balancer_port
  application_port              = var.application_port
  target_group_protocol_version = var.target_group_protocol_version
  health_check_path             = var.health_check_path
  vpc_id                        = aws_vpc.vpc.id
  subnet_ids                    = [for subnet in aws_subnet.public_subnet : subnet.id]
  certificate_arn               = data.aws_acm_certificate.issued.arn
  alb_egress_cidr_blocks        = [var.vpc_cidr]
  alb_target_ids                = [for instance in aws_instance.ec2 : instance.id]
}
