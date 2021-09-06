variable "name_prefix" {
  type = string
}
variable "env" {
  type = string
}
variable "modalidade" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "services_ports" {
  type = list(string)
}
variable "list_ips" {
}
variable "app" {
  type = string
}
variable "projeto" {
  type = string
}
variable "clustrer_eks" {
  type = string
}

variable "protocol" {
    type = string

  
}