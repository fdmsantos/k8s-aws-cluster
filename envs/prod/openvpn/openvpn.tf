provider "aws" {
  region  = var.region
}

locals {
  # Common tags to be assigned to all resources
  common-tags = {
    terraform   = "true"
    environment = var.env
  }
}

terraform {
  backend "s3" {
    region  = "eu-west-1"
    bucket  = "fsantos-k8s-terraform-state"
    key     = "envs/prod/openvpn/terraform.tfstate"
    encrypt = "true"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "eu-west-1"
    bucket = "fsantos-k8s-terraform-state"
    key    = "envs/prod/vpc/terraform.tfstate"

  }
}

data "terraform_remote_state" "route53" {
  backend = "s3"
  config = {
    region = "eu-west-1"
    bucket = "fsantos-k8s-terraform-state"
    key    = "envs/prod/route53/terraform.tfstate"

  }
}

data "aws_ami" "openvpn-server-ami" {
  most_recent      = true
  name_regex       = var.openvpn-ami
  owners           = ["amazon"]
}


module "openvpn" {
  source                         = "../../../modules/project/openvpn"
  env                            = var.env
  region                         = var.region
  # Security Group Data
  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr                       = data.terraform_remote_state.vpc.outputs.vpc_cidr
  # OpenVPN Server Data
  ami                            = data.aws_ami.openvpn-server-ami.id
  subnets_ids                    = data.terraform_remote_state.vpc.outputs.public_subnets_ids
  keypair                        = var.openvpn-server-keypair
  openvpn-backup-bucket-name     = var.openvpn-backup-bucket-name
  openvpn-master-password        = var.openvpn-master-password
  # Route 53
  primary_zone_id                = data.terraform_remote_state.route53.outputs.zone_id
  domain                         = data.terraform_remote_state.route53.outputs.domain
  common-tags                    = local.common-tags
}