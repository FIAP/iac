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
    region = "sa-east-1"
    shared_credentials_file = ".aws/credentials"
}

# VPC
resource "aws_vpc" "Checkpoint_1_VPC" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "Checkpoint 1 VPC"  
    }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "Checkpoint_1_IGW" {
    vpc_id = aws_vpc.Checkpoint_1_VPC.id

    tags = {
        Name = "Checkpoint 1 IGW"
    }
}

# SUBNET
resource "aws_subnet" "Checkpoint_1_Public_Subnet" {
    vpc_id                  = aws_vpc.Checkpoint_1_VPC.id
    cidr_block              = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "sa-east-1a"

    tags = {
        Name = "Checkpoint 1 Public Subnet"
    }
}

# ROUTE TABLE
resource "aws_route_table" "Checkpoint_1_Public_Route_Table" {
    vpc_id = aws_vpc.Checkpoint_1_VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Checkpoint_1_IGW.id
    }

    tags = {
        Name = "Checkpoint 1 Public Route Table"
    }
}

# SUBNET ASSOCIATION
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Checkpoint_1_Public_Subnet.id
  route_table_id = aws_route_table.Checkpoint_1_Public_Route_Table.id
}

# SECURITY GROUP
resource "aws_security_group" "Checkpoint_1_Security_Group" {
    name        = "Checkpoint_1_Security_Group"
    description = "Checkpoint 1 Security Group"
    vpc_id      = aws_vpc.Checkpoint_1_VPC.id
    
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
        description = "SSH - TCP/22 from All"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "HTTP - TCP/80 from All"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Work Security Group"
    }
}

# EC2 INSTANCES
resource "aws_instance" "nagios" {
    ami                    = "ami-09344f463b780bd4c"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.Checkpoint_1_Public_Subnet.id
    vpc_security_group_ids = [aws_security_group.Checkpoint_1_Security_Group.id]
	user_data = <<-EOF
        #!/bin/bash
        # Nagios Core Install Instructions
        # https://support.nagios.com/kb/article/nagios-core-installing-nagios-core-from-source-96.html
        yum update -y
        setenforce 0
        cd /tmp
        yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
        yum install -y perl-Net-SNMP
        yum install -y unzip httpd php gd gd-devel perl postfix
        cd /tmp
        wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz
        tar xzf nagioscore.tar.gz
        cd /tmp/nagioscore-nagios-4.4.6/
        ./configure
        make all
        make install-groups-users
        usermod -a -G nagios apache
        make install
        make install-daemoninit
        systemctl enable httpd.service
        make install-commandmode
        make install-config
        make install-webconf
        iptables -I INPUT -p tcp --destination-port 80 -j ACCEPT
        ip6tables -I INPUT -p tcp --destination-port 80 -j ACCEPT
        htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
        service httpd start
        service nagios start
        cd /tmp
        wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.3.3.tar.gz
        tar zxf nagios-plugins.tar.gz
        cd /tmp/nagios-plugins-release-2.3.3/
        ./tools/setup
        ./configure
        make
        make install
        service nagios restart
        echo done > /tmp/nagioscore.done
	EOF
    
    tags = {
        Name = "nagios"
    }
}

resource "aws_instance" "node_a" {
    ami                    = "ami-09344f463b780bd4c"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.Checkpoint_1_Public_Subnet.id
    vpc_security_group_ids = [aws_security_group.Checkpoint_1_Security_Group.id]
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
