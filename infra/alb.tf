#
# POLICY
#


data "aws_s3_bucket" "log-bucket" {
  bucket = "lognium-tf-eu-dev"
}

data "aws_iam_policy_document" "alb-log-delivery-to-s3" {
  version = "2012-10-17"
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::156460612806:root"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      data.aws_s3_bucket.log-bucket.arn,
      "${data.aws_s3_bucket.log-bucket.arn}/*"
    ]
  }
}

#
# VARIABLES
#

variable "stage" {
  type    = string
  default = "dev"
}

variable "domain-name-external" {
  type    = string
  default = "api-eu.dev.datadeft.eu"
}

variable "domain-name-internal" {
  type    = string
  default = "api-eu-int.dev.datadeft.eu"
}

variable "dns-zone-id" {
  type    = string
  default = "Z0506084GN4SNGJCW1I2"
}

#
## AWS S3
#

resource "aws_s3_bucket_policy" "allow-alb-logs" {
  bucket = data.aws_s3_bucket.log-bucket.id
  policy = data.aws_iam_policy_document.alb-log-delivery-to-s3.json
}

#
## AWS VPC
#

resource "aws_vpc" "datadeft-dev" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "datadeft-dev"
    Stage = "dev"
  }
}

resource "aws_internet_gateway" "datadeft-dev" {
  vpc_id = aws_vpc.datadeft-dev.id
  tags = {
    Name  = "datadeft-dev"
    Stage = "dev"
  }
}

resource "aws_route_table" "datadeft-dev" {
  vpc_id = aws_vpc.datadeft-dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.datadeft-dev.id
  }
  tags = {
    Name  = "datadeft-dev"
    Stage = "dev"
  }
}

resource "aws_subnet" "datadeft-dev-eu-west-1a" {
  vpc_id                  = aws_vpc.datadeft-dev.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true


  tags = {
    Name  = "datadeft-dev-eu-west-1a"
    Stage = "dev"
  }
}

resource "aws_subnet" "datadeft-dev-eu-west-1b" {
  vpc_id                  = aws_vpc.datadeft-dev.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name  = "datadeft-dev-eu-west-1b"
    Stage = "dev"
  }
}

resource "aws_security_group" "allow-ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.datadeft-dev.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "84.225.149.127/32",
      "178.48.217.203/32"
    ]
  }

  ingress {
    description = "Backend Port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    description = "Backend Port"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "datadeft-dev-ssh-in"
    Stage = "dev"
  }
}

resource "aws_route_table_association" "test_pub_route" {
  subnet_id      = aws_subnet.datadeft-dev-eu-west-1a.id
  route_table_id = aws_route_table.datadeft-dev.id
}


#
# AWS EC2 Instance
#

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "datadeft-dev-instance-profile-role" {
  name               = "datadeft-dev"
  path               = "/instance/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "datadeft-dev" {
  name = "datadeft-dev"
  role = aws_iam_role.datadeft-dev-instance-profile-role.name
}

resource "aws_instance" "datadeft-dev" {

  availability_zone           = "eu-west-1a"
  instance_type               = "t4g.micro"
  ami                         = "ami-0394eb760ce9d91f4"
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.datadeft-dev.id
  key_name             = "datadeft-dev"

  subnet_id              = aws_subnet.datadeft-dev-eu-west-1a.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_type           = "gp2"
    volume_size           = 16
    tags = {
      Name  = "datadeft-dev-eu-west-1b"
      Stage = "dev"
    }
  }

  tags = {
    Name  = "datadeft-dev-eu-west-1b"
    Stage = "dev"
  }
}


module "alb" {
  source = "s3::https://s3-eu-west-1.amazonaws.com/datadeft-tf/modules/alb/0.0.1/alb.zip"
  name   = "datadeft-dev"

  security-groups = [aws_security_group.allow-ssh.id]

  subnets = [
    aws_subnet.datadeft-dev-eu-west-1a.id,
    aws_subnet.datadeft-dev-eu-west-1b.id
  ]

  logging-bucket = "lognium-tf-eu-dev"
  logging-prefix = "alb"
  stage          = "dev"
}

resource "aws_lb_target_group" "datadeft-dev" {
  name     = "datadeft-dev"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.datadeft-dev.id
}

resource "aws_lb_target_group_attachment" "datadeft-dev" {
  target_group_arn = aws_lb_target_group.datadeft-dev.arn
  target_id        = aws_instance.datadeft-dev.id
  port             = 8000
}


module "acm" {
  source                    = "s3::https://s3-eu-west-1.amazonaws.com/datadeft-tf/modules/acm/0.1.0/acm.zip"
  domain-name               = var.domain-name-internal
  subject-alternative-names = []
  stage                     = var.stage
  dns-zone-id               = var.dns-zone-id
}

resource "aws_lb_listener" "datadeft-dev" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:eu-west-1:651831719661:loadbalancer/app/datadeft-dev/f0c4fde8b8bdf184"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = module.acm.cert-arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.datadeft-dev.arn
  }
}

resource "aws_route53_record" "datadeft-dev-loadbalancer-internal" {
  zone_id = var.dns-zone-id
  name    = var.domain-name-internal
  type    = "CNAME"
  ttl     = "300"
  records = ["datadeft-dev-1078168668.eu-west-1.elb.amazonaws.com"]
}


#
## AWS CLOUDFRONT
#

module "acm-us-east-1-certificate" {
  source                    = "s3::https://s3-eu-west-1.amazonaws.com/datadeft-tf/modules/acm-us-east-1/0.0.4/acm-us-east-1.zip"
  domain-name               = var.domain-name-external
  subject-alternative-names = []
  stage                     = var.stage
  dns-zone-id               = var.dns-zone-id
  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}


module "cloudfront" {
  source             = "s3::https://s3-eu-west-1.amazonaws.com/datadeft-tf/modules/cloudfront-api/0.0.8/cloudfront-api.zip"
  origin-domain-name = var.domain-name-internal
  domain-aliases     = [var.domain-name-external]
  acm-cert-arn       = module.acm-us-east-1-certificate.cert-arn
  dns-zone-id        = var.dns-zone-id
  logging-bucket     = "lognium-tf-eu-dev"
  logging-prefix     = "cloudfront"
  stage              = var.stage
}
