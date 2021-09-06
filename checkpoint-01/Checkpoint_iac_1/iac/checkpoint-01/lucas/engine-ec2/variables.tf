variable "ami" {
  description = "ami image"
  type = string
}

variable "type_instance" {
  description = "type of instance"
  type = string
}

variable "ip_public" {
  description = "false or true"
  type = bool
}

variable "key_ssh_name" {
  description = "ssh instance .pem"
  type = string
}


variable "type_volume" {
  description = "type volume instance"
  type = string
}


variable "size_volume" {
  description = "Size volume instance"
  type = number
}


variable "del_on_termination" {
  description = "Delete block storage"
}

variable "subnet_id" {
    description = "id subnet"
    type = string

}


variable "vpc_security_group_ids" {
    type = list(string)
}

variable "tag" {
  type = string
  
}
variable "private_ip" {
  type = string
}