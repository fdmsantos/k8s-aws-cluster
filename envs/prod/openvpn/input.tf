variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "sg-operations-cidr" {
  type = string
}

variable "openvpn-ami" {
  type = string
}

variable "openvpn-server-keypair" {
  type = string
}

variable "openvpn-backup-bucket-name" {
  type = string
}

variable "openvpn-master-password" {
  type = string
}

variable "openvpn_secondary_private_ip" {
  type  = string
}

variable "openvpn_network" {
  type = string
}