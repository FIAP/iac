output "vpc" {
  value = aws_vpc.vpc.id
}
output "aws_internet_gateway" {
  value = aws_internet_gateway.vpc-gw.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "aws_route_table_dmz" {
  value = aws_route_table.route-dmz.id
}

output "subnet-dmz-0" {
  value = aws_subnet.vpc-public-0.id
}