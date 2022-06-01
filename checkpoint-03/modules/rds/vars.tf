##################################
#Grupos de Segurança Rede Privada#
##################################

variable "sn_vpc10_priv_1a_id" {}

variable "sn_vpc10_priv_1c_id" {}

# DB PARAMETER GROUP
variable "family" {
  type = string
  default = "mysql8.0"
}

variable "charset" {
  type = string
  default = "utf8"
}

variable "engine" {
  type = string
  default = "mysql"
}

variable "engine_version" {
  type = string
  default = "8.0.23"
}

variable "instance_class" {
  type = string
  default = "db.t3.small"
}

variable "storage_type" {
  type = string
  default = "gp2"
}

variable "allocated_storage" {
  type = number
  default = 20
}

variable "db_name" {
  type = string
  default = "notifier"
}

variable "db_user" {
  type = string
  default = "admin"
}

variable "db_password" {
  type = string
  default = "adminpwd"
}

variable "sg_priv_id" {}