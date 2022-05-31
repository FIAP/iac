output "sg_pub_id" {
  value = "${aws_security_group.sg_pub.id}"
}

output "sg_priv_id" {
  value = "${aws_security_group.sg_priv.id}"
}