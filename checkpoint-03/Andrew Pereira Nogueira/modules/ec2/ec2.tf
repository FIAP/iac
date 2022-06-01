# CODIGO REFERENTE A SERVICOS PARA EC2

### SECURITY GROUP
resource "aws_security_group" "Security_Group_SubPub" {
    name        = "Security_Group_SubPub"
    description = "Security Group SubPub"
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
    vpc_id      = "${var.vpc_id}"
    
    ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 3306
        to_port     = 3306
        protocol    = "TCP"
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

data "template_file" "user_data" {
    template = "${file("./modules/ec2/userdata-notifier.sh")}"
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
    vpc_security_group_ids = [aws_security_group.Security_Group_SubPub.id]
    key_name               = "${var.ssh_key}"
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

### APPLICATION LOAD BALANCER
resource "aws_lb" "elb_ws" {
    name               = "elb-ws"
    load_balancer_type = "application"
    subnets            = ["${var.sn_vpc10_pub_1a_id}", "${var.sn_vpc10_pub_1c_id}"]
    security_groups    = [aws_security_group.Security_Group_SubPub.id]
    
    tags = {
        Name = "elb_ws"
    }
}

### APPLICATION LOAD BALANCER TARGET GROUP
resource "aws_lb_target_group" "elb_aws" {
    name     = "elb-aws"
    vpc_id   = "${var.vpc_id}"
    protocol = "${var.protocol}"
    port     = "${var.port}"

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
    protocol          = "${var.protocol}"
    port              = "${var.port}"
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.elb_aws.arn
    }
}

### AUTO SCALING GROUP
resource "aws_autoscaling_group" "asg_ws" {
    name                = "asg_ws"
    vpc_zone_identifier = ["${var.sn_vpc10_pub_1a_id}", "${var.sn_vpc10_pub_1c_id}"]
    desired_capacity    = "${var.desired_capacity}"
    min_size            = "${var.min_size}"
    max_size            = "${var.max_size}"
    target_group_arns   = [aws_lb_target_group.elb_aws.arn]

    launch_template {
        id      = aws_launch_template.aws_lt.id
        version = "$Latest"
    }
   
}