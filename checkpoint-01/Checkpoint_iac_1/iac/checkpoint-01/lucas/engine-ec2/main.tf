resource "aws_instance" "ec2-main" {
  ami                         = var.ami
  instance_type               = var.type_instance
  associate_public_ip_address = var.ip_public != "" ? var.ip_public : true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name = var.key_ssh_name
  private_ip = var.private_ip
  root_block_device {
    volume_type           = var.type_volume != "" ? var.type_volume : "gp2"
    volume_size           = var.size_volume != "" ? var.size_volume : 8
    delete_on_termination = var.del_on_termination != "" ? var.del_on_termination : true
  }

   tags = {
    Name = var.tag
  }
}