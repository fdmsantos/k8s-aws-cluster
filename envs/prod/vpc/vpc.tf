provider "aws" {
  region  = var.region
}

terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "fsantos-k8s-terraform-state"
    key = "envs/prod/vpc/terraform.tfstate"
    encrypt = "true"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

