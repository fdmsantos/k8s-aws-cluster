output "openvpn-web-url" {
  value = "https://${aws_route53_record.web_vpn.name}:${var.sg_vpn_tcp_connection_port}"
}