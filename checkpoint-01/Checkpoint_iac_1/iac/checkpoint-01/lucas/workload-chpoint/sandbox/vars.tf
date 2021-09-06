variable "type_instance" {
  description = "type of instance"
  type        = string
  default = "t2.micro"

}


variable "key_ssh_name" {
  description = "ssh instance .pem"
  type        = string
  default = "minhachavepessoal"
}

variable "type_volume" {
  description = "type volume instance"
  type        = string
  default = "gp2"
}

variable "size_volume" {
  description = "Size volume"
  type        = number
  default = 8 
}

variable "del_on_termination" {
  description = "Delete block storage"
  default = true
}

