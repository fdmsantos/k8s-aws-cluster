variable "vpc_id" {
  type = string
}

variable "sg_operations_cidr" {
  type = string
}

variable "sg_vpn_udp_connection_port" {
  type = number
  default = 1194
}

variable "sg_vpn_udp_connection_source_cidr" {
  type = string
}

variable "sg_vpn_tcp_connection_port" {
  type = number
  default = 943
}

variable "sg_vpn_tcp_connection_source_cidr" {
  type = string
}