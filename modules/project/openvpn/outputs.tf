output "openvpn-customer-web-client-url" {
  value = "https://${aws_route53_record.web_vpn.name}:${var.sg_openvpn_webclient_customer_port}"
}