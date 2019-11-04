module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "kubernetes-openvpn-server-sg"
  description = "Security Group To OpenVPN server"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.sg_vpn_udp_connection_port
      to_port     = var.sg_vpn_udp_connection_port
      protocol    = "udp"
      description = "VPN Connection"
      cidr_blocks = var.sg_vpn_udp_connection_source_cidr
    },
    {
      from_port   = var.sg_vpn_tcp_connection_port
      to_port     = var.sg_vpn_tcp_connection_port
      protocol    = "tcp"
      description = "HTTPS Conection"
      cidr_blocks = var.sg_vpn_tcp_connection_source_cidr
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.sg_operations_cidr
    },
  ]
}