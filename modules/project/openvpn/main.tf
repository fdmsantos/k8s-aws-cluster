data "template_file" "openvpn-server-ec2-userdata" {
  template = file("${path.module}/templates/openvpn-userdata.tpl")
}

data "template_file" "openvpn-server-ec2-policy" {
  template = file("${path.module}/templates/openvpn-ec2-policy-s3.tpl")
  vars = {
    openvpn_backup_bucket = var.openvpn-backup-bucket-name
  }
}

data "template_file" "openvpn-server-assume-role-policy" {
  template = file("${path.module}/templates/openvpn-assume-role-policy.tpl")
  vars = {
    openvpn_backup_bucket = var.openvpn-backup-bucket-name
  }
}

module "openvpn-sg" {
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
      description = "SSH Admin Operations"
    },
  ]

  egress_rules = ["all-all"]
}


module "openvpn-ec2-policy" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name             = "openvpn-ec2-s3-policy"
  path             = "/"
  description      = "Policy to OpenVPN Servers access to S3 Bucket"
  policy           = data.template_file.openvpn-server-ec2-policy.rendered
}

module "openvpn-server-ec2-role" {
  source                = "../../aws/iam/role"
  name                  = "openvpn-ec2-role"
  assume_role_policy    = data.template_file.openvpn-server-assume-role-policy.rendered
  policy_arns           = [module.openvpn-ec2-policy.arn]
  env                   = var.env
}

module "openvpn-server" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  ami                         = var.server_ami
  name                        = var.server_name
  instance_type               = var.server_instance_type

  vpc_security_group_ids      = [module.openvpn-sg.this_security_group_id]
  subnet_id                   = var.server_subnet_id
  key_name                    = var.server_keypair
  user_data                   = data.template_file.openvpn-server-ec2-userdata.rendered
  associate_public_ip_address = true
  iam_instance_profile        = module.openvpn-server-ec2-role.name

  tags = {
    Terraform   = "true"
    Environment = var.env
  }

}

module "allocate-public-ip" {
  source      = "../../aws/networking/associate-public-eip-instance"
  instance_id = module.openvpn-server.id[0]
}

