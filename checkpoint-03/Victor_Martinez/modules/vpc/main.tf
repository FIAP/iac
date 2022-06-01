#VPC
resource "aws_vpc" "vpc10" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.vpc_dns_hostnames

  tags = {
    Name = "vpc10"
  }
}
#INTERNET GATEWAY
resource "aws_internet_gateway" "igw_vpc10" {
  vpc_id = aws_vpc.vpc10.id

  tags = {
    Name = "igw_vpc10"
  }
}
#SUBNET
resource "aws_subnet" "sn_vpc10_pub_1a" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = var.sn_vpc10_pub_1a_cidr
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = "us-east-1a"

  tags = {
    Name = "sn_vpc10_pub_1a"
  }
}

resource "aws_subnet" "sn_vpc10_pub_1c" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = var.sn_vpc10_pub_1c_cidr
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = "us-east-1c"

  tags = {
    Name = "sn_vpc10_pub_1c"
  }
}

resource "aws_subnet" "sn_vpc10_priv_1a" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = var.sn_vpc10_priv_1a_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn_vpc10_priv_1a"
  }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = var.sn_vpc10_priv_1c_cidr
  availability_zone = "us-east-1c"

  tags = {
    Name = "sn_vpc10_priv_1c"
  }
}
#ROUTE TABLE
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc10.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc10.id
  }

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table" "rt_priv" {
  vpc_id = aws_vpc.vpc10.id

  tags = {
    Name = "rt_priv"
  }
}
#SUBNET ASSOCIATION
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.sn_pub_1a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sn_priv_1a.id
  route_table_id = aws_route_table.rt_priv.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.sn_pub_1c.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "D" {
  subnet_id      = aws_subnet.sn_priv_1c.id
  route_table_id = aws_route_table.rt_priv.id
}