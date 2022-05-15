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
resource "aws_vpc" "vpc10" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

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
resource "aws_subnet" "sn_vpc10_pub_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_pub_1a"
    }
}
# SUBNET
resource "aws_subnet" "sn_vpc10_priv_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_priv_1a"
    }
}
# SUBNET
resource "aws_subnet" "sn_vpc10_pub_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_pub_1c"
    }
}
# SUBNET
resource "aws_subnet" "sn_vpc10_priv_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.4.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_priv_1c"
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
  subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
  route_table_id = aws_route_table.Public_Route_Table.id
}
# SUBNET ASSOCIATION
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
  route_table_id = aws_route_table.Priv_Route_Table.id
}

# SUBNET ASSOCIATION
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
  route_table_id = aws_route_table.Public_Route_Table.id
}
# SUBNET ASSOCIATION
resource "aws_route_table_association" "D" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
  route_table_id = aws_route_table.Priv_Route_Table.id
}
# SECURITY GROUP
resource "aws_security_group" "Pub_Security_Group" {
    name        = "Pub_Security_Group"
    description = "Security Group"
    vpc_id      = aws_vpc.vpc10.id
    
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
        Name = "Pub Security Group"
    }
}
# SECURITY GROUP
resource "aws_security_group" "Priv_Security_Group" {
    name        = "Priv_Security_Group"
    description = "Security Group"
    vpc_id      = aws_vpc.vpc10.id
    
    egress {
        description = "All to all"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    
    tags = {
        Name = "Priv Security Group"
    }
}
#SUBNET GROUP
resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = [aws_subnet.sn_vpc10_priv_1a.id, aws_subnet.sn_vpc10_priv_1c.id]

  tags = {
    Name = "Subnet Group"
  }
}
#PARAMETER GROUP
resource "aws_db_parameter_group" "Parameter_Group" {
  name        = "parametergroup"
  family      = "mysql8.0"
  description = "RDS Parameter Group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8"
  }
}
#DATA BASE
resource "aws_db_instance" "rds_db_notifier" {
    identifier             = "rds-db-notifier"
    engine                 = "mysql"
    engine_version         = "8.0.23"
    instance_class         = "db.t3.small"
    storage_type           = "gp2"
    allocated_storage      = "20"
    max_allocated_storage  = 0
    monitoring_interval    = 0
    name                   = "notifier"
    username               = "admin"
    password               = "adminpwd"
    skip_final_snapshot    = true
    db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
    parameter_group_name   = aws_db_parameter_group.Parameter_Group.name
    vpc_security_group_ids = [ aws_security_group.Priv_Security_Group.id ]

    tags = {
        Name = "rds-db-notifier"
    }

}
#TARGET GROUP
resource "aws_lb_target_group" "elb_target_group" {
  name     = "elb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc10.id

  tags = {
        Name = "elb_target_group"
    }
}
# APPLICATION LOAD BALANCER
resource "aws_lb" "elb_ws" {
    name               = "elb-ws"
    load_balancer_type = "application"
    subnets            = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    security_groups    = [aws_security_group.Pub_Security_Group.id]
    
    tags = {
        Name = "elb-ws"
    }
}
# APPLICATION LOAD BALANCER LISTENER
resource "aws_lb_listener" "listener_lb" {
    load_balancer_arn = aws_lb.elb_ws.arn
    protocol          = "HTTP"
    port              = "80"
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.elb_target_group.arn
    }
}
# AUTO SCALING GROUP
resource "aws_autoscaling_group" "asg_ws" {
    name                = "asg_ws"
    vpc_zone_identifier = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    desired_capacity    = "2"
    min_size            = "1"
    max_size            = "4"
    target_group_arns   = [aws_lb_target_group.elb_target_group.arn]

    launch_template {
        id      = aws_launch_template.Launch_template.id
        version = "$Latest"
    }
   
}
# EC2 LAUNCH TEMPLATE
data "template_file" "user_data" {
    template = "${file("./app/userdata-notifier.sh")}"
}

resource "aws_launch_template" "Launch_template" {
    name                   = "Launch-template"
    image_id               = "ami-02e136e904f3da870"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.Pub_Security_Group.id]
    key_name               = "vockey"
    user_data              = "${base64encode(data.template_file.user_data.rendered)}"


    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "User data"
        }
    }

    tags = {
        Name = "Launch template"
    }
}