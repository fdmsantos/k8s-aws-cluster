variable "name" {
  type = string
}

variable "assume_role_policy" {
  type = string
}

variable "env" {
  type = string
}

variable "policy_arns" {
  type = list(string)
}

variable "create_instance_profile" {
  type    = bool
  default = false
}