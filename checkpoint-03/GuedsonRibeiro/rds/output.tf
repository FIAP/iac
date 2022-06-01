# DB INSTANCE
output "rds_endpoint" {
    value = aws_db_instance.rdsdbnotifier.endpoint
}