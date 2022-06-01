# DB INSTANCE
output "rds_endpoint" {
    value = "${aws_db_instance.db_notifier.endpoint}"
}
