#SUBNET GROUP
resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = [aws_subnet.sn_vpc10_priv_1a.id, aws_subnet.sn_vpc10_priv_1c.id]

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
    engine                 = "mysql"
    engine_version         = "8.0.23"
    instance_class         = "db.t3.small"
    storage_type           = "gp2"
    allocated_storage      = "20"
    max_allocated_storage  = 0
    monitoring_interval    = 0
    name                   = "notifier"
    username               = "admin"
    password               = "adminpwd"
    multi_az = true
    skip_final_snapshot    = true
    db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
    parameter_group_name   = aws_db_parameter_group.Parameter_Group.name
    vpc_security_group_ids = [ aws_security_group.Priv_Security_Group.id ]

    tags = {
        Name = "rds-db-notifier"
    }

}