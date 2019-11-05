provider "aws" {
  region  = var.region
}

terraform {
  backend "s3" {
    region  = "eu-west-1"
    bucket  = "fsantos-k8s-terraform-state"
    key     = "envs/prod/common/terraform.tfstate"
    encrypt = "true"
  }
}

module "elastic-ip-manager" {
  source = "../../../modules/project/elastic-ip-manager"
}