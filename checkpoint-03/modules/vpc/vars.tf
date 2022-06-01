## VPC ##

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

## DNS ##

variable "vpc_dns_hostname" {
  default = true
}

# SUB PUB ##
variable "sn_vpc10_pub_1a_cidr" {
  default = "10.0.1.0/24"
}

variable "sn_vpc10_pub_1c_cidr" {
  default = "10.0.2.0/24"
}

## SUB PRIC ##

variable "sn_vpc10_priv_1a_cidr" {
  default = "10.0.3.0/24"
}

variable "sn_vpc10_priv_1c_cidr" {
  default = "10.0.4.0/24"
}