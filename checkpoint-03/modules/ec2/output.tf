
##SEG PUB##
output "sg_pub_id" {
  value = "${aws_security_group.sg_pub.id}"
}

##SEG PRIV##
output "sg_priv_id" {
  value = "${aws_security_group.sg_priv.id}"
}