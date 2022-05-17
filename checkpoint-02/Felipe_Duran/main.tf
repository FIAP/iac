#PROVIDER
terraform {

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#REGION
provider "aws" {
    region = "us-east-1"
    shared_credentials_file = ".aws/credentials"
}

#VPC

resource "aws_vpc" "vpc10" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

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
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_pub_1a"
    }
}

resource "aws_subnet" "sn_vpc10_pub_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_pub_1c"
    }
}

#PRIVATES SUBNETS

resource "aws_subnet" "sn_vpc10_priv_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.3.0/24"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_priv_1a"
    }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.4.0/24"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_priv_1c"
    }
}

#ROUTE TABLE
resource "aws_route_table" "vpc10_route_table_pub" {
    vpc_id = aws_vpc.vpc10.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }

    tags = {
        Name = "vpc10 Public Route Table"
    }
}
resource "aws_route_table" "vpc10_route_table_priv" {
    vpc_id = aws_vpc.vpc10.id
	
	
    tags = {
        Name = "vpc10 Public Route Table"
    }
}
#PUBLIC SUBNET ASSOCIATION
resource "aws_route_table_association" "sn_association_1a_pub" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
  route_table_id = aws_route_table.vpc10_route_table_pub.id
}
resource "aws_route_table_association" "sn_association_1c_pub" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
  route_table_id = aws_route_table.vpc10_route_table_pub.id
}

#PRIVATES SUBNET ASSOCIATION
resource "aws_route_table_association" "sn_association_1b_priv" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
  route_table_id = aws_route_table.vpc10_route_table_priv.id
}
resource "aws_route_table_association" "sn_association_1d_priv" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
  route_table_id = aws_route_table.vpc10_route_table_priv.id
}

#PUBLIC SECURITY GROUP
resource "aws_security_group" "SG_pub" {
    name        = "SG_pub"
    vpc_id      = aws_vpc.vpc10.id
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
    }
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SG_pub"
    }
}

#PRIVATE SECURITY GROUP
resource "aws_security_group" "SG_priv" {
    name        = "SG_priv"
    vpc_id      = aws_vpc.vpc10.id
     
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SG_priv"
    } 
}

#DB SUBNET GROUP
resource "aws_db_subnet_group" "rds_sn_group" {
    name       = "rds_sn_group"
    subnet_ids = [aws_subnet.sn_vpc10_priv_1a.id, aws_subnet.sn_vpc10_priv_1c.id]

    tags = {
        Name = "rds_sn_group"
    }
}

resource "aws_db_parameter_group" "rds_pg" {
    name   = "rds-pg"
    family = "mysql8.0"
    
    parameter {
        name  = "character_set_server"
        value = "utf8"
    }
    
    parameter {
        name  = "character_set_database"
        value = "utf8"
    }
}

#DB INSTANCE
resource "aws_db_instance" "rds_db_notifier" {
    identifier             = "rds-db-notifier"
    engine                 = "mysql"
    engine_version         = "8.0.23"
    instance_class         = "db.t3.micro"
    storage_type           = "gp2"
    allocated_storage      = "20"
    max_allocated_storage  = 0
    monitoring_interval    = 0
    name                   = "notifier"
    username               = "admin"
    password               = "adminpwd"
    skip_final_snapshot    = true
    db_subnet_group_name   = aws_db_subnet_group.rds_sn_group.name
    parameter_group_name   = aws_db_parameter_group.rds_pg.name
    vpc_security_group_ids = [ aws_security_group.SG_priv.id ]

    tags = {
        Name = "rds_db_notifier"
    }

}


#LAUNCH TEMPLATE
resource "aws_launch_template" "ws_1" {
    name                   = "ws_1"
    image_id               = "ami-02e136e904f3da870"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.SG_pub.id]
    key_name               = "vockey"

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "ws_1"
        }
    }
    }

#LOAD BALANCER
resource "aws_lb" "elb_ws" {
  name               = "elb-ws"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG_pub.id]
  subnets            = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]

  tags = {
    Name = "elb_ws"
  }
}

resource "aws_lb_target_group" "tg_ws" {
  name     = "tg-ws"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc10.id


  tags = {
      Name = "tg_ws"
  }

}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.elb_ws.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_ws.arn
  }
}

#AUTO SCALING GROUP
resource "aws_autoscaling_group" "asg_ws" {
    name                = "asg_ws"
    vpc_zone_identifier = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    desired_capacity    = "2"
    min_size            = "1"
    max_size            = "4"
    target_group_arns   = [aws_lb_target_group.tg_ws.arn]

    launch_template {
        id      = aws_launch_template.ws_1.id
        version = "$Latest"
    }
   
}