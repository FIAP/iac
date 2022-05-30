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


