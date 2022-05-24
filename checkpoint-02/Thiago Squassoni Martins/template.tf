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

# SUBNET PUBLIC
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

# SUBNET PRIVATE

resource "aws_subnet" "sn_vpc10_priv_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_priv_1a"
    }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.4.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_priv_1c"
    }
}

# PUBLIC ROUTE TABLE
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

# PRIVATE ROUTE TABLE

resource "aws_route_table" "rt_vpc10_priv" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "rt_vpc10_priv"
    }
}

# PRIVATE SUBNET ASSOCIATION
resource "aws_route_table_association" "as_priv_1a_subnet" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
  route_table_id = aws_route_table.rt_vpc10_priv.id
}

resource "aws_route_table_association" "as_priv_1c_subnet" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
  route_table_id = aws_route_table.rt_vpc10_priv.id
}

# PUBLIC SUBNET ASSOCIATION

resource "aws_route_table_association" "as_pub_1a_subnet" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
  route_table_id = aws_route_table.rt_vpc10_pub.id
}

resource "aws_route_table_association" "as_pub_1c_subnet" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
  route_table_id = aws_route_table.rt_vpc10_pub.id
}

# PUBLIC SECURITY GROUP
resource "aws_security_group" "sg_vpc10_pub" {
    name        = "sg_vpc10_pub"
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
        Name = "sg_vpc10_pub"
    }
}

# PRIVATE SECURITY GROUP

resource "aws_security_group" "sg_vpc10_priv" {
    name        = "sg_vpc10_priv"
    description = "Security Group private"
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

    tags = {
        Name = "sg_vpc10_priv"
    }
}

# DATABASE SUBNET
resource "aws_db_subnet_group" "rds-sn-group" {
    name = "rds-sn-group"
    description = "rds-sn-group"
    subnet_ids = [ aws_subnet.sn_vpc10_priv_1a.id, aws_subnet.sn_vpc10_priv_1c.id ]
    
    tags = {
        Name = "rds-sn-group"
    }
}

# PARAMETER GROUP
resource "aws_db_parameter_group" "rds-pg" {
    name = "rds-pg"
    family = "mysql8.0"

    parameter {
      name = "character_set_server"
      value = "utf8"
      apply_method = "immediate"
    }
    
    parameter {
      name = "character_set_database"
      value = "utf8"
      apply_method = "immediate"
    }

    description = "Habilita o UTF8 no banco dados"

    tags = {
      Name = "rds-pg"
    }
}

# DB INSTANCE
resource "aws_db_instance" "rds_db_notifier" {
    identifier             = "rds-db-notifier"
    engine                 = "mysql"
    engine_version         = "8.0"
    instance_class         = "db.t3.micro"
    storage_type           = "gp2"
    allocated_storage      = "20"
    max_allocated_storage  = 0
    monitoring_interval    = 0
    name                   = "notifier"
    username               = "admin"
    password               = "adminpwd"
    skip_final_snapshot    = true
    db_subnet_group_name   = aws_db_subnet_group.rds-sn-group.name
    parameter_group_name   = aws_db_parameter_group.rds-pg.name
    vpc_security_group_ids = [aws_security_group.sg_vpc10_priv.id]
    port = "3306"
    multi_az = true
    publicly_accessible = true

    tags = {
        Name = "rds-db-notifier"
    }

}

# APPLICATION LOAD BALANCER TARGET GROUP
resource "aws_lb_target_group" "elb-ws" {
    name     = "elb-ws"
    vpc_id   = aws_vpc.vpc10.id
    protocol = "HTTP"
    port     = 80
    protocol_version = "HTTP1"

    health_check {
      path = "/"
      port = 80
      protocol = "HTTP"
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 2
      interval = 5
    }

    tags = {
        Name = "elb-ws"
    }
}

# APPLICATION LOAD BALANCER
resource "aws_lb" "elb-ws" {
    name               = "elb-ws"
    load_balancer_type = "application"
    subnets            = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    security_groups    = [aws_security_group.sg_vpc10_pub.id]
    internal = false
    
    tags = {
        Name = "elb-ws"
    }
}

# APPLICATION LOAD BALANCER LISTENER
resource "aws_lb_listener" "lb-listener" {
    load_balancer_arn = aws_lb.elb-ws.arn
    protocol          = "HTTP"
    port              = 80
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.elb-ws.arn
    }
}

# EC2 LAUNCH TEMPLATE
data "template_file" "user_data" {
    template = "${file("./modules/ec2/userdata-notifier.sh")}"
}

resource "aws_launch_template" "asg-ws-ls" {
    name                   = "asg-ws-ls"
    image_id               = "ami-02e136e904f3da870"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg_vpc10_pub.id]
    key_name               = "vockey"
    user_data              = "${base64encode(data.template_file.user_data.rendered)}"


    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "asg-ws-ls"
        }
    }

    tags = {
        Name = "asg-ws-ls"
    }
}

# AUTO SCALING GROUP
resource "aws_autoscaling_group" "asg_ws" {
    name                = "asg_ws"
    vpc_zone_identifier = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    desired_capacity    = "2"
    min_size            = "1"
    max_size            = "4"
    target_group_arns   = [aws_lb_target_group.elb-ws.arn]

    launch_template {
        id      = aws_launch_template.asg-ws-ls.id
        version = "$Latest"
    }
   
}