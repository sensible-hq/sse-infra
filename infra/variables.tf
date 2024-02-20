variable "stage" {
  type        = string
  description = "Stage"
}

variable "aws_account_id" {
  type        = string
  description = "The used AWS account id"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values in list format"
}

variable "public_subnet_azs" {
  type        = list(string)
  description = "Public Subnet Availability Zones in list format"
}

variable "certificate_domain" {
  type        = string
  description = "The domain name of the certificate e.g. example.com"
}

variable "load_balancer_port" {
  type        = number
  description = "Load balancer user facing port e.g. 443"
}

variable "application_port" {
  type        = number
  description = "Application port e.g. 80"
}

variable "target_group_protocol_version" {
  type        = string
  description = "HTTP1 or HTTP2"
}

variable "health_check_path" {
  type        = string
  description = "Health check application path e.g. /health"
}
