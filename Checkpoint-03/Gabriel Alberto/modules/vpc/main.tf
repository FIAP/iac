# VPC
resource "aws_vpc" "vpc10" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.vpc_dns_hostnames

  tags = {
    Name = "vpc10"
  }
}
# INTERNET GATEWAY
resource "aws_internet_gateway" "igw_vpc10" {
  vpc_id = aws_vpc.vpc10.id

  tags = {
    Name = "igw_vpc10"
  }
}
# SUBNET
resource "aws_subnet" "sn_pub_1a" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = var.sn_pub_1a_cidr
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = "us-east-1a"

  tags = {
    Name = "sn_pub_1a"
  }
}
# SUBNET
resource "aws_subnet" "sn_pub_1c" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = var.sn_pub_1c_cidr
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = "us-east-1c"

  tags = {
    Name = "sn_pub_1c"
  }
}
# SUBNET
resource "aws_subnet" "sn_priv_1a" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = var.sn_priv_1a_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn_priv_1a"
  }
}
# SUBNET
resource "aws_subnet" "sn_priv_1c" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = var.sn_priv_1c_cidr
  availability_zone = "us-east-1c"

  tags = {
    Name = "sn_priv_1c"
  }
}
# ROUTE TABLE
resource "aws_route_table" "Public_Route_Table" {
  vpc_id = aws_vpc.vpc10.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc10.id
  }

  tags = {
    Name = "Public Route Table"
  }
}
# ROUTE TABLE
resource "aws_route_table" "Priv_Route_Table" {
  vpc_id = aws_vpc.vpc10.id

  tags = {
    Name = "Priv Route Table"
  }
}
# SUBNET ASSOCIATION
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sn_pub_1a.id
  route_table_id = aws_route_table.Public_Route_Table.id
}
# SUBNET ASSOCIATION
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sn_priv_1a.id
  route_table_id = aws_route_table.Priv_Route_Table.id
}

# SUBNET ASSOCIATION
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.sn_pub_1c.id
  route_table_id = aws_route_table.Public_Route_Table.id
}
# SUBNET ASSOCIATION
resource "aws_route_table_association" "D" {
  subnet_id      = aws_subnet.sn_priv_1c.id
  route_table_id = aws_route_table.Priv_Route_Table.id
}