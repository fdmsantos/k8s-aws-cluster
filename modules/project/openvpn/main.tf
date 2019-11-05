// Data
data "template_file" "openvpn-ec2-userdata" {
  template = file("${path.module}/templates/openvpn-userdata.tpl")
  vars = {
    openvpn_backup_bucket             = var.openvpn-backup-bucket-name
    openvpn-master-password-parameter = module.openvpn-master-user-ssm-parameter.names[0]
    region                            = var.region
  }
}

data "template_file" "openvpn-ec2-s3-policy" {
  template = file("${path.module}/templates/openvpn-ec2-s3-policy.tpl")
  vars = {
    openvpn_backup_bucket = var.openvpn-backup-bucket-name
  }
}

data "template_file" "openvpn-ec2-ssm-policy" {
  template = file("${path.module}/templates/openvpn-ec2-ssm-policy.tpl")
  vars = {
    openvpn-master-password-parameter = module.openvpn-master-user-ssm-parameter.names[0]
  }
}

// Policys
module "openvpn-ec2-s3-policy" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name             = "${var.name}-s3-policy"
  path             = "/"
  description      = "Policy to OpenVPN Servers access to S3 Bucket"
  policy           = data.template_file.openvpn-ec2-s3-policy.rendered
}

module "openvpn-ec2-ssm-policy" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name             = "${var.name}-ssm-policy"
  path             = "/"
  description      = "Policy to OpenVPN Servers access to SSM Parameter"
  policy           = data.template_file.openvpn-ec2-ssm-policy.rendered
}

module "openvpn-ec2-role" {
  source                  = "../../aws/ec2/role"
  name                    = "${var.name}-role"
  policy_arns             = [module.openvpn-ec2-s3-policy.arn, module.openvpn-ec2-ssm-policy.arn]
  env                     = var.env
}

// Security Group
module "openvpn-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.name}-sg"
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


// SSM Parameter
module "openvpn-master-user-ssm-parameter" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=master"
  parameter_write = [{
    name            = "/${var.env}/${var.name}/users/openvpn"
    value           = var.openvpn-master-password
    type            = "SecureString"
    overwrite       = "true"
    description     = "OpenVPN Master user password"
  }]

  tags = {
    terraform   = "true"
    environment = var.env
  }
}

// Server
module "openvpn-server" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  ami                         = var.ami
  name                        = var.name
  instance_type               = var.instance_type

  vpc_security_group_ids      = [module.openvpn-sg.this_security_group_id]
  subnet_id                   = var.subnet_id
  key_name                    = var.keypair
  user_data                   = data.template_file.openvpn-ec2-userdata.rendered
  associate_public_ip_address = true
  iam_instance_profile        = module.openvpn-ec2-role.name

  tags = {
    terraform   = "true"
    environment = var.env
  }

}

// Attach Allocate IP
module "allocate-public-ip" {
  source      = "../../aws/networking/associate-public-eip-instance"
  instance_id = module.openvpn-server.id[0]
}

