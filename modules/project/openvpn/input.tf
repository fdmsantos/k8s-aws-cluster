variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}

variable "sg_openvpn_webclient_customer_port" {
  type    = string
  default = 9091
}

variable "vpc_cidr" {
  type = string
}

variable "name" {
  type    = string
  default = "openvpn"
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnets_ids" {
  type = list(string)
}

variable "keypair" {
  type = string
}

variable "openvpn-backup-bucket-name" {
  type = string
}

variable "openvpn-master-password" {
  type = string
}

variable "common-tags" {
  type    = object({})
  default = {}
}

variable "public_domain" {
  type    = string
}

variable "public_zone_id" {
  type    = string
}

variable "private_domain" {
  type    = string
}

variable "private_zone_id" {
  type    = string
}

variable "openvpn_secondary_private_ip" {
  type    = string
}