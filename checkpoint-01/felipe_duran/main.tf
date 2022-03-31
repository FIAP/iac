# PROVIDER
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# REGION
provider "aws" {
    region = "us-east-1"
    shared_credentials_file = ".aws/credentials"
}

# VPC
resource "aws_vpc" "Hello_VPC" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "Hello VPC"  
    }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "Hello_IGW" {
    vpc_id = aws_vpc.Hello_VPC.id

    tags = {
        Name = "Hello IGW"
    }
}

# SUBNET
resource "aws_subnet" "Hello_Public_Subnet" {
    vpc_id                  = aws_vpc.Hello_VPC.id
    cidr_block              = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "Hello Public Subnet"
    }
}

# ROUTE TABLE
resource "aws_route_table" "Hello_Public_Route_Table" {
    vpc_id = aws_vpc.Hello_VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Hello_IGW.id
    }

    tags = {
        Name = "Hello Public Route Table"
    }
}

# SUBNET ASSOCIATION
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Hello_Public_Subnet.id
  route_table_id = aws_route_table.Hello_Public_Route_Table.id
}

# SECURITY GROUP
resource "aws_security_group" "Hello_Security_Group" {
    name        = "Hello_Security_Group"
    description = "Hello Security Group"
    vpc_id      = aws_vpc.Hello_VPC.id
    
    egress {
        description = "All to All"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
    }
    
    ingress {
        description = "TCP/22 from All"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "TCP/80 from All"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Work Security Group"
    }
}

# EC2 INSTANCE
resource "aws_instance" "hello-instance" {
    ami                    = "ami-0c02fb55956c7d316"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.Hello_Public_Subnet.id
    vpc_security_group_ids = [aws_security_group.Hello_Security_Group.id]

    tags = {
        Name = "hello-instance"
    }
}
