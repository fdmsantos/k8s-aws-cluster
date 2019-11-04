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

variable "server_name" {
  type    = string
  default = "kubernetes-openvpn-server"
}

variable "server_ami" {
  type = string
}

variable "server_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "server_subnet_id" {
  type = string
}

variable "server_keypair" {
  type = string
}

variable "openvpn-backup-bucket-name" {
  type = string
}