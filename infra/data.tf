data "aws_acm_certificate" "issued" {
  domain   = var.certificate_domain
  statuses = ["ISSUED"]
}
