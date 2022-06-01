#########################################################################    
                    #CONFIGURAÇÃO DE SEGURAÇA DAS SUBNETES#
#########################################################################

##################################
#Grupos de Segurança Rede Publica#
##################################

resource "aws_security_group" "sg_pub" {
    name        = "sg_pub"
    description = "Security Group public"
    vpc_id      = "${var.vpc_id}"

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

##################################
#Grupos de Segurança Rede Privada#
##################################

resource "aws_security_group" "sg_priv" {
    name        = "sg_priv"
    description = "Security Group private"
    vpc_id      = "${var.vpc_id}"

    ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
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
        Name = "sg_priv"
    }
}

#########################################################################    
            #CONFIGURAÇÃO LOAD BALANCER E AUTOSCALING#
#########################################################################


############################
#Criação do Target Group####
############################

resource "aws_lb_target_group" "elb-aws" {
    name     = "elb-aws"
    vpc_id   = "${var.vpc_id}"
    protocol = "${var.protocol}"
    port     = "${var.port}"

    tags = {
        Name = "elb-aws"
    }
}

##########################
#Config Listener Porta 80#
##########################

resource "aws_lb_listener" "lis_vpc10" {
    load_balancer_arn = aws_lb.elb-ws.arn
    protocol          = "${var.protocol}"
    port              = "${var.port}"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.elb-aws.arn
    }
}

######################################################################
##Criação do ELB e Associaçao do ELB as Subnets e Grupo de Segurança##
######################################################################

resource "aws_lb" "elb-ws" {
    name               = "elb-ws"
    load_balancer_type = "application"
    subnets            = ["${var.sn_vpc10_pub_1a_id}", "${var.sn_vpc10_pub_1c_id}"]
    security_groups    = [aws_security_group.sg_pub.id]

    tags = {
        Name = "elb-ws"
    }
}

####################################################
##Template para criação de novas instancias de EC2##
####################################################S

data "template_file" "user_data" {
    template = "${file("./modules/ec2/script/userdata-notifier.sh")}"
vars = {
        rds_endpoint = "${var.rds_endpoint}"
        rds_user     = "${var.rds_user}"
        rds_password = "${var.rds_password}"
        rds_name     = "${var.rds_name}"
    }
}

resource "aws_launch_template" "aws_lt" {
    name                   = "aws_lt"
    image_id               = "${var.ami}"
    instance_type          = "${var.instance_type}"
    vpc_security_group_ids = [aws_security_group.sg_pub.id]
    key_name               = "${var.ssh_key}"
    user_data              = "${base64encode(data.template_file.user_data.rendered)}"


    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "ws_"
        }
    }

    tags = {
        Name = "aws_lt"
    }
}

########################
#Criação do AutoScaling#
########################

resource "aws_autoscaling_group" "asg_ws" {
    name                = "asg-ws"
    vpc_zone_identifier = ["${var.sn_vpc10_pub_1a_id}", "${var.sn_vpc10_pub_1c_id}"]
    desired_capacity    = "${var.desired_capacity}"
    min_size            = "${var.min_size}"
    max_size            = "${var.max_size}"
    target_group_arns   = [aws_lb_target_group.elb-aws.arn]

    launch_template {
        id      = aws_launch_template.aws_lt.id
        version = "$Latest"
    }

}