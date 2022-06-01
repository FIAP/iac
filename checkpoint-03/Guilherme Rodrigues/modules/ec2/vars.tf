#SG
variable "vpc_id" {}

#Load Balancer
variable "protocol" {
  type = string
  default = "HTTP"
}

variable "port" {
  type = number
  default = 80
}

variable "sn_vpc10_pub_1a_id" {}

variable "sn_vpc10_pub_1c_id" {}

#Launch template
variable "rds_endpoint" {}

variable "rds_user" {}

variable "rds_password" {}

variable "rds_name" {}

variable "ami" {
  type    = string
  default = "ami-02e136e904f3da870"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_key" {
  type    = string
  default = "vockey"
}

#Auto Scaling
variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 8
}