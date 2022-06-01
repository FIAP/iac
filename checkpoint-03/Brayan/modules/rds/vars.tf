#SUBNET E SEGURANÇA
variable "sn_priv_1a_id" {
  type = string
}

variable "sn_priv_1c_id" {
  type = string
}

variable "sg_priv_id" {
  type = string
}

#DATA BASE
variable "engine" {
  default     = "mysql"
}

variable "engine_version" {
  default     = "8.0.23"
}

variable "instance_class" {
  default     = "db.t3.small"
}

variable "storage_type" {
  default     = "gp2"
}

variable "allocated_storage" {
  default     = "20"
}

variable "max_allocated_storage" {
  default     = "0"
}

variable "monitoring_interval" {
  default     = "0"
}

variable "name" {
  default     = "notifier"
}

variable "username" {
  default     = "admin"
}

variable "password" {
  default     = "adminpwd"
}

variable "family" {
  default     = "mysql8.0"
}

variable "db_name" {
  default     = "notifier"
}