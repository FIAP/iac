#DB Subnet Group
resource "aws_db_subnet_group" "rds_vpc10_sn_group" {
  name       = "vpc10-rds-sn-grp"
  subnet_ids = ["${var.sn_vpc10_priv_1a_id}", "${var.sn_vpc10_priv_1c_id}"]

  tags = {
    "Name" = "rds_vpc10_sn_group"
  }
}

#DB Parameter Group
resource "aws_db_parameter_group" "rds_vpc10_par_grp" {
  name   = "vpc10-rds-par-grp"
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

#instância rds
resource "aws_db_instance" "rds_notifier_db" {
  identifier              = "rds-notifier-db"
  multi_az                = "${var.multi_az}"
  engine                  = "${var.engine}"
  engine_version          = "${var.engine_version}"
  instance_class          = "${var.instance_class}"
  storage_type            = "${var.storage_type}"
  allocated_storage       = "${var.allocated_storage}"
  max_allocated_storage   = 0
  monitoring_interval     = 0
  name                    = "${var.db_name}"
  username                = "${var.db_user}"
  password                = "${var.db_password}"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.rds_vpc10_sn_group.name
  parameter_group_name    = aws_db_parameter_group.rds_vpc10_par_grp.name
  vpc_security_group_ids  = ["${var.vpc10_Security_Group_priv_id}"]

  tags = {
    "Name" = "rds_notifier_db"
  }
}