# snapsoft-test
stage                         = "snapsoft-test"
aws_account_id                = "100139537474"
vpc_cidr                      = "10.0.0.0/16"
public_subnet_cidrs           = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_azs             = ["eu-central-1a", "eu-central-1b"]
certificate_domain            = "meetapp.snapsoft.io"
load_balancer_port            = 443
application_port              = 8000
target_group_protocol_version = "HTTP1"
health_check_path             = "/health-check"
