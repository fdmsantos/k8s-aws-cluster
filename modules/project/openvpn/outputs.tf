output "openvpn-customer-web-client-url" {
  value = "https://${aws_route53_record.public_vpn_domain.name}:${var.sg_openvpn_webclient_customer_port}"
}