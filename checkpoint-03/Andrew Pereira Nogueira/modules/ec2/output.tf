### OUTPUT DE EC2

output "Security_Group_SubPub_id" {
  value = "${aws_security_group.Security_Group_SubPub.id}"
}

output "Security_Group_SubPriv_id" {
  value = "${aws_security_group.Security_Group_SubPriv.id}"
}
