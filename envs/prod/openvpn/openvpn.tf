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

data "aws_ami" "openvpn-ami" {
  most_recent      = true
  name_regex       = var.openvpn-ami
  owners           = ["amazon"]
}


module "openvpn" {
  source                         = "../../../modules/project/openvpn"
  env                            = var.env
  # Security Group Data
  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_operations_cidr             = var.sg-operations-cidr
  # OpenVPN Server Data
  server_ami                     = data.aws_ami.openvpn-ami.id
  server_subnet_id               = data.terraform_remote_state.vpc.outputs.public_subnet_1_id
  server_keypair                 = var.openvpn-server-keypair
  openvpn-backup-bucket-name     = var.openvpn-backup-bucket-name

}