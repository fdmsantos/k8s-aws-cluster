provider "aws" {
  region  = var.region
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
  sg_operations_cidr             = var.sg-operations-cidr
  # OpenVPN Server Data
  ami                            = data.aws_ami.openvpn-server-ami.id
  subnet_id                      = data.terraform_remote_state.vpc.outputs.public_subnet_1_id
  keypair                        = var.openvpn-server-keypair
  openvpn-backup-bucket-name     = var.openvpn-backup-bucket-name
  openvpn-master-password        = var.openvpn-master-password

}