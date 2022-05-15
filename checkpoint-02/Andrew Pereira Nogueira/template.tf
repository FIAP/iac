### PROVIDER
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

### REGION
provider "aws" {
    region = "us-east-1"
    shared_credentials_file = ".aws/credentials"
}

### VPC
resource "aws_vpc" "vpc10" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

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

resource "aws_subnet" "sn_vpc10_priv_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_priv_1a"
    }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.4.0/24"
    map_public_ip_on_launch = "true"
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

### SECURITY GROUP
resource "aws_security_group" "Security_Group_SubPub" {
    name        = "Security_Group_SubPub"
    description = "Security Group SubPub"
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
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Security Group SubPub"
    }
}

resource "aws_security_group" "Security_Group_SubPriv" {
    name        = "Security_Group_SubPriv"
    description = "Security Group SubPriv"
    vpc_id      = aws_vpc.vpc10.id
    
    ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
    }

        egress {
        description = "All to All"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "Security Group SubPriv"
    }
}

### DB SUBNET GROUP
resource "aws_db_subnet_group" "rds_vpc10_sn_group" {
    name       = "rds-vpc10-sn-group"
    subnet_ids = [aws_subnet.sn_vpc10_priv_1a.id, aws_subnet.sn_vpc10_priv_1c.id]

    tags = {
        Name = "rds-vpc10-sn-group"
    }
}

### DB PARAMETER GROUP
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

### DB INSTANCE
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
    vpc_security_group_ids = [aws_security_group.Security_Group_SubPriv.id]

    tags = {
        Name = "rds-db-notifier"
    }

}

### APPLICATION LOAD BALANCER TARGET GROUP
resource "aws_lb_target_group" "elb_aws" {
    name     = "elb-aws"
    vpc_id   = aws_vpc.vpc10.id
    protocol = "HTTP"
    port     = "80"

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
        Name = "elb_aws"
    }
}

### APPLICATION LOAD BALANCER LISTENER
resource "aws_lb_listener" "lis_vpc10" {
    load_balancer_arn = aws_lb.elb_ws.arn
    protocol          = "HTTP"
    port              = "80"
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.elb_aws.arn
    }
}

### APPLICATION LOAD BALANCER
resource "aws_lb" "elb_ws" {
    name               = "elb-ws"
    load_balancer_type = "application"
    subnets            = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    security_groups    = [aws_security_group.Security_Group_SubPub.id]
    
    tags = {
        Name = "elb_ws"
    }
}

### EC2 LAUNCH TEMPLATE
data "template_file" "user_data" {
    template = "${file("./modules/ec2/userdata-notifier.sh")}"
}

resource "aws_launch_template" "aws_lt" {
    name                   = "aws_lt"
    image_id               = "ami-02e136e904f3da870"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.Security_Group_SubPub.id]
    key_name               = "vockey"
    user_data              = "${base64encode(data.template_file.user_data.rendered)}"


    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "ws_"
        }
    }

    tags = {
        Name = "ws_"
    }
}

### AUTO SCALING GROUP
resource "aws_autoscaling_group" "asg_ws" {
    name                = "asg_ws"
    vpc_zone_identifier = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    desired_capacity    = "2"
    min_size            = "1"
    max_size            = "4"
    target_group_arns   = [aws_lb_target_group.elb_aws.arn]

    launch_template {
        id      = aws_launch_template.aws_lt.id
        version = "$Latest"
    }
   
}