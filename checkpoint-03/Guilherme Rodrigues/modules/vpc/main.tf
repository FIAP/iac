#VPC
resource "aws_vpc" "vpc10" {
  cidr_block           = "${var.vpc10_cidr}"
  enable_dns_hostnames = "${var.vpc10_dns_hostname}"

  tags = {
    "Name" = "vpc10"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw_vpc10" {
  vpc_id = aws_vpc.vpc10.id

  tags = {
    "Name" = "igw_vpc10"
  }
}

#Subnet pub
resource "aws_subnet" "sn_vpc10_pub_1a" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = "${var.sn_vpc10_pub_1a_cidr}"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "sn_vpc10_pub_1a"
  }
}

resource "aws_subnet" "sn_vpc10_pub_1c" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = "${var.sn_vpc10_pub_1c_cidr}"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1c"

  tags = {
    "Name" = "sn_vpc10_pub_1c"
  }
}

#Subnet priv
resource "aws_subnet" "sn_vpc10_priv_1a" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = "${var.sn_vpc10_priv_1a_cidr}"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "sn_vpc10_priv_1a"
  }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = "${var.sn_vpc10_priv_1c_cidr}"
  availability_zone = "us-east-1c"

  tags = {
    "Name" = "sn_vpc10_priv_1c"
  }
}

# ROUTE TABLE pub
resource "aws_route_table" "vpc10_route_table_pub" {
    vpc_id = aws_vpc.vpc10.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }

    tags = {
        Name = "vpc10_route_table_pub"
    }
}

# ROUTE TABLE priv
resource "aws_route_table" "vpc10_route_table_priv" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "vpc10_route_table_priv"
    }
}

# SUBNET ASSOCIATION pub_a
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
  route_table_id = aws_route_table.vpc10_route_table_pub.id
}

# SUBNET ASSOCIATION pub_c
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
  route_table_id = aws_route_table.vpc10_route_table_pub.id
}

# SUBNET ASSOCIATION priv_a
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
  route_table_id = aws_route_table.vpc10_route_table_priv.id
}

# SUBNET ASSOCIATION priv_c
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
  route_table_id = aws_route_table.vpc10_route_table_priv.id
}