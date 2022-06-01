output "vpc10_Security_Group_pub_id" {
  value = "${aws_security_group.vpc10_Security_Group_pub.id}"
}

output "vpc10_Security_Group_priv_id" {
  value = "${aws_security_group.vpc10_Security_Group_priv.id}"
}