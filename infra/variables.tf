variable vpc_cidr {
    description = "CIDR block of VPC"
    default = "10.0.0.0/16"
}

variable public_subnet_cidrs {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable public_subnet_azs {
  type        = list(string)
  description = "Public Subnet Availability Zones"
  default     = ["eu-central-1a", "eu-central-1b"]
}
