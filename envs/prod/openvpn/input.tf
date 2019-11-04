variable "region" {
  type = string
}

variable "sg_operations_cidr" {
  type = string
}

variable "sg_vpn_udp_connection_port" {
  type = number
}

variable "sg_vpn_udp_connection_source_cidr" {
  type = string
}

variable "sg_vpn_tcp_connection_port" {
  type = number
}

variable "sg_vpn_tcp_connection_source_cidr" {
  type = string
}