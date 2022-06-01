#SUBNET GROUP
resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = [var.sn_priv_1a_id, var.sn_priv_1c_id]

  tags = {
    Name = "Subnet Group"
  }
}
#PARAMETER GROUP
resource "aws_db_parameter_group" "Parameter_Group" {
  name        = "parametergroup"
  family      = "mysql8.0"
  description = "RDS Parameter Group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8"
  }
}
#DATA BASE
resource "aws_db_instance" "rds_db_notifier" {
  identifier             = "rds-db-notifier"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  storage_type           = var.storage_type
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  monitoring_interval    = var.monitoring_interval
  name                   = var.name
  username               = var.username
  password               = var.password
  multi_az               = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  parameter_group_name   = aws_db_parameter_group.Parameter_Group.name
  vpc_security_group_ids = [var.sg_priv_id]

  tags = {
    Name = "rds-db-notifier"
  }

}