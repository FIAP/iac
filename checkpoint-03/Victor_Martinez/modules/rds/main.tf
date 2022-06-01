#DB SUBNET GROUP
resource "aws_db_subnet_group" "sn_group" {
  name       = "sn_group"
  subnet_ids = [var.sn_priv_1a_id, var.sn_priv_1c_id]

  tags = {
    Name = "sn_group"
  }
}
#PARAMETER GROUP
resource "aws_db_parameter_group" "p_group" {
  name        = "p_group"
  family      = "mysql8.0"
  description = "p_group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8"
  }
}
#DB
resource "aws_db_instance" "db_notifier" {
  identifier             = "db-notifier"
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
  db_subnet_group_name   = aws_db_subnet_group.sn_group.name
  parameter_group_name   = aws_db_parameter_group.p_group.name
  vpc_security_group_ids = [var.sg_priv_id]

  tags = {
    Name = "db_notifier"
  }

}