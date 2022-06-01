# CODIGO REFERENTE A SERVICOS DE REDE

### VPC
resource "aws_vpc" "vpc10" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_hostnames = "${var.vpc_dns_hostname}"

    tags = {
        Name = "vpc10"  
    }
}

### INTERNET GATEWAY
resource "aws_internet_gateway" "igw_vpc10" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "igw_vpc10"
    }
}

### SUBNETS
resource "aws_subnet" "sn_vpc10_pub_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "${var.sn_vpc10_pub_1a_cidr}"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_pub_1a"
    }
}

resource "aws_subnet" "sn_vpc10_pub_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "${var.sn_vpc10_pub_1c_cidr}"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_pub_1c"
    }
}

resource "aws_subnet" "sn_vpc10_priv_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "${var.sn_vpc10_priv_1a_cidr}"
    map_public_ip_on_launch = "false"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_priv_1a"
    }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "${var.sn_vpc10_priv_1c_cidr}"
    map_public_ip_on_launch = "false"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_priv_1c"
    }
}

### TABELA DE ROTEAMENTO
resource "aws_route_table" "Tabela_Roteamento_Publica" {
    vpc_id = aws_vpc.vpc10.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }

    tags = {
        Name = "Tabela Roteamento Publica"
    }
}

resource "aws_route_table" "Tabela_Roteamento_Privada" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "Tabela Roteamento Privada"
    }
}

### SUBNET ASSOCIATION
resource "aws_route_table_association" "Tabela_Roteamento_Publica_1a" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
  route_table_id = aws_route_table.Tabela_Roteamento_Publica.id
}

resource "aws_route_table_association" "Tabela_Roteamento_Publica_1c" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
  route_table_id = aws_route_table.Tabela_Roteamento_Publica.id
}

resource "aws_route_table_association" "Tabela_Roteamento_Privada_1a" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
  route_table_id = aws_route_table.Tabela_Roteamento_Privada.id
}

resource "aws_route_table_association" "Tabela_Roteamento_Privada_1c" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
  route_table_id = aws_route_table.Tabela_Roteamento_Privada.id
}