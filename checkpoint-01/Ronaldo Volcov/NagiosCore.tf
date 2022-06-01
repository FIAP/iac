##Checkpoint01 - 1TCNR Cloud Computing [Ronaldo Volcov rm84422]

#################
#Config Provider#
#################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

###############
#Config Região#
###############

provider "aws" {
    region = "us-east-1"
    shared_credentials_file = ".aws/credentials"
}
#####################
#Criação da Work VPC#
#####################

resource "aws_vpc" "Work_VPC" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "Work VPC"  
    }
}

##########################
#Criação Internet Gateway#
##########################

resource "aws_internet_gateway" "Work_IGW" {
    vpc_id = aws_vpc.Work_VPC.id

    tags = {
        Name = "Work IGW"
    }
}

################
#Criação Subnet#
################

resource "aws_subnet" "Work_Public_Subnet" {
    vpc_id                  = aws_vpc.Work_VPC.id
    cidr_block              = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "Work Public Subnet"
    }
}

#####################
#Criação Route Table#
#####################

resource "aws_route_table" "Work_Public_Route_Table" {
    vpc_id = aws_vpc.Work_VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Work_IGW.id
    }

    tags = {
        Name = "Work Public Route Table"
    }
}

######################
#Associação da Subnet#
######################

resource "aws_route_table_association" "Assoc_1" {

  subnet_id      = aws_subnet.Work_Public_Subnet.id
  route_table_id = aws_route_table.Work_Public_Route_Table.id

}
#####################
#Grupos de Segurança#
#####################

resource "aws_security_group" "Work_Nagios_Security_Group" {

    name        = "Work_Nagios_Security_Group"
    description = "Grupos de Seguranca do Nagios"
    vpc_id      = aws_vpc.Work_VPC.id
    
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

# EC2 INSTANCE NAGIOS
resource "aws_instance" "nagios" {
    ami                    = "ami-0c02fb55956c7d316"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.Work_Public_Subnet.id
    vpc_security_group_ids = [aws_security_group.Work_Nagios_Security_Group.id]
    user_data              = <<-EOF
   #!/bin/bash
        # Security-Enhanced Linux
        sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
        # Prerequisites 
        yum update -y
        yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
        # Downloading the Source
        cd /tmp
        wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz
        tar xzf nagioscore.tar.gz
        # Compile
        cd /tmp/nagioscore-nagios-4.4.6/
        ./configure
        make all
        # Create User And Group
        make install-groups-users
        usermod -a -G nagios apache
        # Install Binaries
        make install
        # Install Service / Daemon
        make install-daemoninit
        systemctl enable httpd.service
        # Install Command Mode
        make install-commandmode
        # Install Configuration Files
        make install-config
        # Install Apache Config Files
        make install-webconf
        # Configure Firewall
        firewall-cmd --zone=public --add-port=80/tcp
        firewall-cmd --zone=public --add-port=80/tcp --permanent
        # Create nagiosadmin User Account
        htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
        # Start Apache Web Server
        systemctl start httpd.service
        # Start Service / Daemon
        systemctl start nagios.service
        echo done > /tmp/nagioscore.done
	EOF

    tags = {
        Name = "nagios"
    }

}    

# EC2 INSTANCE Node_A
resource "aws_instance" "node_a" {
    ami                    = "ami-0c02fb55956c7d316"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.Work_Public_Subnet.id
    vpc_security_group_ids = [aws_security_group.Work_Nagios_Security_Group.id]
    user_data = <<-EOF
        #!/bin/bash
        # NCPA Agent Install instructions
        # https://assets.nagios.com/downloads/ncpa/docs/Installing-NCPA.pdf
        yum update -y
        rpm -Uvh https://assets.nagios.com/downloads/ncpa/ncpa-latest.el7.x86_64.rpm
        systemctl restart ncpa_listener.service
        echo done > /tmp/ncpa-agent.done
        # SNMP Agent install instructions
        # https://www.site24x7.com/help/admin/adding-a-monitor/configuring-snmp-linux.html
        yum update -y
        yum install net-snmp -y
        echo "rocommunity public" >> /etc/snmp/snmpd.conf
        service snmpd restart
        echo done > /tmp/snmp-agent.done
	EOF

    tags = {
        Name = "node_a"
    }

}