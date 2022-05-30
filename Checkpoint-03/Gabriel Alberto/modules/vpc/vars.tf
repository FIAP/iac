# VPC
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_dns_hostnames" {
  default = true
}

# SUBNETS
variable "sn_pub_1a_cidr" {
  default = "10.0.1.0/24"
}

variable "sn_pub_1c_cidr" {
  default = "10.0.2.0/24"
}

variable "sn_priv_1a_cidr" {
  default = "10.0.3.0/24"
}

variable "sn_priv_1c_cidr" {
  default = "10.0.4.0/24"
}
