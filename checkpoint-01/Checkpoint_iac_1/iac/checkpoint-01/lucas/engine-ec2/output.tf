output "ip_public" {
    value = [aws_instance.ec2-main.public_ip]
}
