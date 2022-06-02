#LAUNCH TEMPLATE
variable "ami" {
  default = "ami-02e136e904f3da870"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ssh_key" {
  default = "vockey"
}
# AUTO SCALING GROUP
variable "desired_capacity" {
  default = "2"
}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "4"
}

# APPLICATION LOAD BALANCER TARGET GROUP
variable "protocol" {
  default = "HTTP"

}

variable "port" {
  default = "80"

}

variable "vpc_id" { 
  type = string
}

variable "sn_pub_1a_id" {
  type = string
}

variable "sn_pub_1c_id" {
  type = string
}

variable "rds_endpoint" {
  type        = string
}

variable "rds_user" {
  default     = "admin"
}
variable rds_password {
  default     = "adminpwd"
}
variable rds_name {
  default     = "notifier"
}