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
}

# VPC
resource "aws_vpc" "vpc10" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "vpc10"  
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw_vpc10" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "igw_vpc10"
    }
}

# Subnet's
resource "aws_subnet" "sn_vpc10_pub_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_pub_1a"
    }
}

resource "aws_subnet" "sn_vpc10_pub_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_pub_1c"
    }
}

resource "aws_subnet" "sn_vpc10_priv_1a" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "sn_vpc10_priv_1a"
  }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
    vpc_id            = aws_vpc.vpc10.id
    cidr_block        = "10.0.4.0/24"
    availability_zone = "us-east-1c"

    tags = {
        Name = "sn_vpc10_priv_1c"
    }
}

# Route Table
resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.vpc10.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }

    tags = {
        Name = "rt_pub"
    }
}

resource "aws_route_table" "rt_priv" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "rt_priv_1c"
    }
}

# Associando a route table
resource "aws_route_table_association" "rta_pub_1a" {
    subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
    route_table_id = aws_route_table.rt_pub.id
}

resource "aws_route_table_association" "rta_pub_1c" {
    subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
    route_table_id = aws_route_table.rt_pub.id
}

resource "aws_route_table_association" "rta_priv_1a" {
    subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
    route_table_id = aws_route_table.rt_priv.id
}

resource "aws_route_table_association" "rta_priv_1c" {
    subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
    route_table_id = aws_route_table.rt_priv.id
}



# SECURITY GROUP
resource "aws_security_group" "sg_pub" {
    name        = "sg_pub"
    description = "Security Group public"
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
        Name = "sg_pub"
    }
}

# EC2 LAUNCH TEMPLATE
data "template_file" "user_data" {
    template = "${file("./sh/userdata-notifier.sh")}"
}

resource "aws_launch_template" "lt_app_notify" {
    name                   = "lt_app_notify"
    image_id               = "ami-02e136e904f3da870"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg_pub.id]
    key_name               = "vockey"
    user_data              = "${base64encode(data.template_file.user_data.rendered)}"


    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "app_notify"
        }
    }

    tags = {
        Name = "lt_app_notify"
    }
}

# APPLICATION LOAD BALANCER
resource "aws_lb" "lb_app_notify" {
    name               = "lb-app-notify"
    load_balancer_type = "application"
    subnets            = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    security_groups    = [aws_security_group.sg_pub.id]
    
    tags = {
        Name = "lb_app_notify"
    }
}

# APPLICATION LOAD BALANCER TARGET GROUP
resource "aws_lb_target_group" "tg_app_notify" {
    name     = "tg-app-notify"
    vpc_id   = aws_vpc.vpc10.id
    protocol = "HTTP"
    port     = "80"

    tags = {
        Name = "tg_app_notify"
    }
}

# APPLICATION LOAD BALANCER LISTENER
resource "aws_lb_listener" "listener_app_notify" {
    load_balancer_arn = aws_lb.lb_app_notify.arn
    protocol          = "HTTP"
    port              = "80"
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg_app_notify.arn
    }
}

# AUTO SCALING GROUP
resource "aws_autoscaling_group" "asg_app_notify" {
    name                = "asg_app_notify"
    vpc_zone_identifier = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    desired_capacity    = "2"
    min_size            = "1"
    max_size            = "4"
    target_group_arns   = [aws_lb_target_group.tg_app_notify.arn]

    launch_template {
        id      = aws_launch_template.lt_app_notify.id
        version = "$Latest"
    }
   
}

# SECURITY GROUP PRIV
resource "aws_security_group" "sg_priv" {
    name        = "sg_priv"
    description = "Security Group private"
    vpc_id      = aws_vpc.vpc10.id

    ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        description = "All to all"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "sg_priv"
    }
}

# DB SUBNET GROUP
resource "aws_db_subnet_group" "rds_vpc10_sn_group" {
    name       = "rds-vpc10-sn-group"
    subnet_ids = [ aws_subnet.sn_vpc10_priv_1a.id, aws_subnet.sn_vpc10_priv_1c.id ]

    tags = {
        Name = "rds-vpc10-sn-group"
    }
}

# DB PARAMETER GROUP
resource "aws_db_parameter_group" "rds_vpc10_pg" {
    name   = "rds-vpc10-pg"
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

# DB INSTANCE
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
    db_subnet_group_name   = aws_db_subnet_group.rds_vpc10_sn_group.name
    parameter_group_name   = aws_db_parameter_group.rds_vpc10_pg.name
    vpc_security_group_ids = [ aws_security_group.sg_priv.id ]

    tags = {
        Name = "rds-db-notifier" 
    }

}