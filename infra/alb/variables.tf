variable "stage" {
  type        = string
  description = "Stage"
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

variable "vpc_id" {
  type        = string
  description = "VPC id"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ids for the load balancer, it requires at least 2 AZs to work"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate arn to use by load balancer"
}

variable "alb_egress_cidr_blocks" {
  type        = list(string)
  description = "Where to allow egress from ALB e.g. VPC cidr"
}

variable "alb_idle_timeout" {
  type        = number
  description = "Idle timeout for the load balancer"
  default     = 1800
}

variable "alb_deletion_protection" {
  type        = bool
  description = "Protect load balancer from accidental deletion"
  default     = false
}

variable "alb_enable_http2" {
  type        = bool
  description = "Load balancer support http2"
  default     = true
}

variable "alb_target_ids" {
  type        = list(string)
  description = "Targets of the load balancer by id"
}
