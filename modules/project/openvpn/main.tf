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
  tags                    = var.common-tags
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

  egress_rules     = ["all-all"]
  tags             = var.common-tags
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

  tags              = var.common-tags
}


// Allocate ElasticIP
resource "aws_eip" "openvpn_eip" {
  vpc              = true
  public_ipv4_pool = "amazon"
  tags = {
    Name                    = "${var.name}-eip"
    elastic-ip-manager-pool = var.name
    terraform               = true
    environment             = var.env
  }
}

// Route 53
resource "aws_route53_record" "web_vpn" {
  zone_id = var.primary_zone_id
  name    = "web.vpn.${var.domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.openvpn_eip.public_ip]
}

// AutoScaling Group
module "openvpn-asg" {
  source                             = "terraform-aws-modules/autoscaling/aws"
  name                               = var.name

  # Launch configuration
  lc_name                            = "${var.name}-lc"
  image_id                           = var.ami
  instance_type                      = var.instance_type
  security_groups                    = [module.openvpn-sg.this_security_group_id]
  key_name                           = var.keypair
  user_data                          = data.template_file.openvpn-ec2-userdata.rendered
  associate_public_ip_address        = true
  iam_instance_profile               = module.openvpn-ec2-role.name
  recreate_asg_when_lc_changes       = true

  # Auto scaling group
  asg_name                           = "${var.name}-asg"
  vpc_zone_identifier                = var.subnets_ids
  health_check_type                  = "EC2"
  health_check_grace_period          = 5
  min_size                           = 1
  max_size                           = 1
  desired_capacity                   = 1
  wait_for_capacity_timeout          = 0

  tags = [
    {
      key                              = "elastic-ip-manager-pool"
      value                            = var.name
      propagate_at_launch              = true
    },
    {
      key                              = "terraform"
      value                            = "true"
      propagate_at_launch              = true
    },
    {
      key                              = "environment"
      value                            = var.env
      propagate_at_launch              = true
    }
  ]
}