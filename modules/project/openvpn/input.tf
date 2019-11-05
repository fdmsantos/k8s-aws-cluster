variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}

variable "sg_operations_cidr" {
  type = string
}

variable "sg_vpn_udp_connection_port" {
  type   = number
  default = 1194
}

variable "sg_vpn_udp_connection_source_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "sg_vpn_tcp_connection_port" {
  type    = number
  default = 943
}

variable "sg_vpn_tcp_connection_source_cidr" {
  type    = string
  default = "0.0.0.0/0"
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

variable "subnet_id" {
  type = string
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