################
#Criação da VPC#
################

resource "aws_vpc" "vpc10" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_hostnames = "${var.vpc_dns_hostname}"

    tags = {
        Name = "vpc10"  
    }
}

##########################
#Criação Internet Gateway#
##########################

resource "aws_internet_gateway" "igw_vpc10" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "igw_vpc10"
    }
}

#########################################################################    
                #CRIAÇÃO DAS SUBNETES PRIVADA E PUBLICA#
#########################################################################

###########################
#Criação da Subnet Publica#
###########################

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

###########################
#Criação da Subnet Privada#
###########################

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
#########################################################################    
#########################################################################

#########################################################################    
                #CONFIGURAÇÃO DAS TABELAS DE ROTEAMENTO#
#########################################################################

##############################################
#Criação da tabela de roteamento Rede Publica#
##############################################

resource "aws_route_table" "rt_vpc10_pub" {
    vpc_id = aws_vpc.vpc10.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }

    tags = {
        Name = "rt_vpc10_pub"
    }
}

##############################################
#Criação da tabela de roteamento Rede Privada#
##############################################

resource "aws_route_table" "rt_vpc10_priv" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "rt_vpc10_priv"
    }
}

################################################
#Associação Tabela de Roteamento a Rede Publica#
################################################

resource "aws_route_table_association" "sa_pub_1a_subnet" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
  route_table_id = aws_route_table.rt_vpc10_pub.id
}

resource "aws_route_table_association" "sa_pub_1c_subnet" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
  route_table_id = aws_route_table.rt_vpc10_pub.id
}

################################################
#Associação Tabela de Roteamento a Rede Privada#
################################################

resource "aws_route_table_association" "sa_priv_1a_subnet" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
  route_table_id = aws_route_table.rt_vpc10_priv.id
}

resource "aws_route_table_association" "sa_priv_1c_subnet" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
  route_table_id = aws_route_table.rt_vpc10_priv.id
}