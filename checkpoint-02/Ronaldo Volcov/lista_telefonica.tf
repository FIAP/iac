/*
Autor: Ronaldo Euclides Volcov RM84422 - Checkpoint 02
*/

#########################################################################    
                #CONFIGURAÇÃO PROVIDER/REGIÃO#
#########################################################################


#####################
#Config Provider AWS#
#####################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#############################
#Config Região e Credenciais#
#############################

provider "aws" {
    region = "us-east-1"
    shared_credentials_file = ".aws/credentials"


#########################################################################    
                        #CONFIGURAÇÃO DA REDE#
#########################################################################
}
#####################
#Criação da Work VPC#
#####################

resource "aws_vpc" "vpc10" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

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
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a" ##AZ

    tags = {
        Name = "sn_vpc10_pub_1a" 
    }
}

resource "aws_subnet" "sn_vpc10_pub_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c" ##AZ

    tags = {
        Name = "sn_vpc10_pub_1c"
    }
}

###########################
#Criação da Subnet Privada#
###########################

resource "aws_subnet" "sn_vpc10_priv_1a" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a" ##AZ

    tags = {
        Name = "sn_vpc10_priv_1a"
    }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.4.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c" ##AZ

    tags = {
        Name = "sn_vpc10_priv_1c"
    }
}

#########################################################################    
                #CONFIGURAÇÃO DAS TABELAS DE ROTEAMENTO#
#########################################################################

##############################################
#Criação da tabela de roteamento Rede Publica#
##############################################

resource "aws_route_table" "Public_Route_Table" {
    vpc_id = aws_vpc.vpc10.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }

    tags = {
        Name = "Public_Route_Table"
    }
}

##############################################
#Criação da tabela de roteamento Rede Privada#
##############################################

resource "aws_route_table" "Private_Route_Table" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "Private_Route_Table"
    }
}

################################################
#Associação Tabela de Roteamento a Rede Publica#
################################################

resource "aws_route_table_association" "Assoc_1_Pub_a" {

  subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
  route_table_id = aws_route_table.Public_Route_Table.id

}

resource "aws_route_table_association" "Assoc_1_Pub_c" {

  subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
  route_table_id = aws_route_table.Public_Route_Table.id

}

################################################
#Associação Tabela de Roteamento a Rede Privada#
################################################

resource "aws_route_table_association" "Assoc_2_Priv_a" {

  subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
  route_table_id = aws_route_table.Private_Route_Table.id

}

resource "aws_route_table_association" "Assoc_2_Priv_c" {

  subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
  route_table_id = aws_route_table.Private_Route_Table.id

}

#########################################################################    
                    #CONFIGURAÇÃO DE SEGURAÇA DAS SUBNETES#
#########################################################################

##################################
#Grupos de Segurança Rede Publica#
##################################

resource "aws_security_group" "sg_vpc10_pub" {

    name        = "Public_Security_Group"
    description = "Grupo de Seguranca Public Network"
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

##################################
#Grupos de Segurança Rede Privada#
##################################

resource "aws_security_group" "sg_vpc10_priv" {

    name        = "Private_Security_Group"
    description = "Grupo de Seguranca Private Network"
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
        from_port   = 3306 ##Porta RDS##
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    
    tags = {
        Name = "sg_vpc10_priv"
    }
}

#########################################################################    
                #CONFIGURAÇÃO DO BANCO DE DADOS RDS#
#########################################################################


################################
#Associação as Subnets Privadas#
################################

resource "aws_db_subnet_group" "sg_vpc10_db_rds"{

    name       = "sg-vpc10-rds"
    subnet_ids = [ aws_subnet.sn_vpc10_priv_1a.id, aws_subnet.sn_vpc10_priv_1c.id ]

    tags = {
        Name = "sg_vpc10_rds"
    }
}

###################################
##Parameter Group UTF8 para o PHP##
###################################

resource "aws_db_parameter_group" "pg_vpc10_db_rds" {
    name   = "pg-vpc10-db-rds"
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


###########################
##Criaçao da Instancia RDS#
###########################

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
    db_subnet_group_name   = aws_db_subnet_group.sg_vpc10_db_rds.name
    parameter_group_name   = aws_db_parameter_group.pg_vpc10_db_rds.name
    vpc_security_group_ids = [ aws_security_group.sg_vpc10_priv.id  ]

    tags = {
        Name = "rds_db_notifier"
    }
}

#########################################################################    
                        #CONFIG EC2 APLICAÇÃO PHP#
#########################################################################

####################################################
##Template para criação de novas instancias de EC2##
####################################################S

data "template_file" "user_data" {
    template = "${file(".script/userdata-notifier.sh")}"
}


resource "aws_launch_template" "lt_app_notify" {
    name                   = "lt-app-notify"
    image_id               = "ami-02e136e904f3da870"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg_vpc10_pub.id]
    key_name               = "key"
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


#########################################################################    
            #CONFIGURAÇÃO LOAD BALANCER E AUTOSCALING#
#########################################################################

######################################################################
##Criação do ELB e Associaçao do ELB as Subnets e Grupo de Segurança##
######################################################################
resource "aws_lb" "elb_ws" {
    name               = "elb-ws"
    load_balancer_type = "application" #Aplicação estará escutando na porta 80 exposto pelos Apaches
    subnets            = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id] ##AZs Public Subnets
    security_groups    = [aws_security_group.sg_vpc10_pub.id] ##SG das Subnets

    
    tags = {
        Name = "elb_ws"
    }
}



############################
#Criação do Target Group####
############################

resource "aws_lb_target_group" "tg_elb_ws" {
    vpc_id   = aws_vpc.vpc10.id
    
    name     = "tg-elb-ws"
    protocol = "HTTP"
    port     = "80"

    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    port                = 80
    interval            = 10

    }

    tags = {
        Name = "tg_elb_ws"
    }
}

##########################
#Config Listener Porta 80#
##########################

resource "aws_lb_listener" "listener_elb_ws" {
    load_balancer_arn = aws_lb.elb_ws.arn
    protocol          = "HTTP"
    port              = "80"
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg_elb_ws.arn
    }
}

########################
#Criação do AutoScaling#
########################

resource "aws_autoscaling_group" "asg_ws" {
    name                = "asg-ws"
    vpc_zone_identifier = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]
    desired_capacity    = "2"
    min_size            = "1"
    max_size            = "4"
    target_group_arns   = [aws_lb_target_group.tg_elb_ws.arn]

    launch_template {
        id      = aws_launch_template.lt_app_notify.id
        version = "$Latest"
    }
   
}


#########################################################################    
            #CONFIGURAÇÃO VPC ENDPOINT#
#########################################################################

resource "aws_vpc_endpoint" "vpc_ep_vpc10" {
  vpc_id            = aws_vpc.vpc10.id
  service_name      = "com.amazonaws.us-east-1.sns"
  vpc_endpoint_type = "Interface"
  security_group_ids    = [aws_security_group.sg_vpc10_pub.id] ##SG AutoScaling

  private_dns_enabled = true

  tags = {
        Name = "vpc_ep_vpc10"
    }
}
#########################################################################    
                        #CONFIGURAÇÃO SNS#
#########################################################################
locals {
  phone_numbers = ["+5511911112222"] ##Array para testar numero
}

resource "aws_sns_topic" "sn_app" {
  name            = "sn-app"
  delivery_policy = jsonencode({  ##Policy para envio do SMS
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false,
      "defaultThrottlePolicy" : {
        "maxReceivesPerSecond" : 1
      }
    }
  })
}

resource "aws_sns_topic_subscription" "topic_sms_subscription" {
  count     = length(local.phone_numbers) ##Valida quantidade de campos
  topic_arn = aws_sns_topic.sn_app.arn
  protocol  = "sms"
  endpoint  = local.phone_numbers[count.index] ##Chamada do Array
}
