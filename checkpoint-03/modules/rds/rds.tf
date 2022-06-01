################################
#Associação as Subnets Privadas#
################################

resource "aws_db_subnet_group" "rds_vpc10_sn_group" {
  name       = "rds_vpc10_sn_group"
  subnet_ids = ["${var.sn_vpc10_priv_1a_id}", "${var.sn_vpc10_priv_1c_id}"]

  tags = {
    Name = "rds_vpc10_sn_group"
  }
}

###################################
##Parameter Group UTF8 para o PHP##
###################################

resource "aws_db_parameter_group" "rds_vpc10_pg" {
  name   = "rds-vpc10-pg"
  family = "${var.family}"

  parameter {
    name  = "character_set_server"
    value = "${var.charset}"
  }

  parameter {
    name  = "character_set_client"
    value = "${var.charset}"
  }
}

###########################
##Criaçao da Instancia RDS#
###########################

resource "aws_db_instance" "rds_db_notifier" {
    identifier             = "rds-db-notifier"
    engine                 = "${var.engine}"
    engine_version         = "${var.engine_version}"
    instance_class         = "${var.instance_class}"
    storage_type           = "${var.storage_type}"
    allocated_storage      = "${var.allocated_storage}"
    max_allocated_storage  = 0
    monitoring_interval    = 0
    name                   = "${var.db_name}"
    username               = "${var.db_user}"
    password               = "${var.db_password}"
    skip_final_snapshot    = true
    db_subnet_group_name   = aws_db_subnet_group.rds_vpc10_sn_group.name
    parameter_group_name   = aws_db_parameter_group.rds_vpc10_pg.name
    vpc_security_group_ids = ["${var.sg_priv_id}"]
    multi_az                = true

    tags = {
        Name = "rds-db-notifier"
    }

}