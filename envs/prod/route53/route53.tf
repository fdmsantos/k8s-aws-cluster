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
    region = "eu-west-1"
    bucket = "fsantos-k8s-terraform-state"
    key = "envs/prod/route53/terraform.tfstate"
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

resource "aws_route53_zone" "main" {
  name           = var.domain
  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  tags           = local.common-tags
}
