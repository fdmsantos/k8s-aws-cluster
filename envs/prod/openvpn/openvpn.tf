provider "aws" {
  region  = var.region
}

terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "fsantos-k8s-terraform-state"
    key = "envs/prod/openvpn/terraform.tfstate"
    encrypt = "true"
  }
}


data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "eu-west-1"
    bucket = "fsantos-k8s-terraform-state"
    key = "envs/prod/vpc/terraform.tfstate"

  }
}

module "openvpn" {
  source = "../../../modules/project/openvpn"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  sg_operations_cidr = var.sg_operations_cidr
  sg_vpn_tcp_connection_port = var.sg_vpn_tcp_connection_port
  sg_vpn_tcp_connection_source_cidr = var.sg_vpn_tcp_connection_source_cidr
  sg_vpn_udp_connection_port = var.sg_vpn_udp_connection_port
  sg_vpn_udp_connection_source_cidr = var.sg_vpn_udp_connection_source_cidr
}
