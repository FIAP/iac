# EC2 INSTANCES
resource "aws_instance" "nagios" {
    ami                    = "ami-0c02fb55956c7d316"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc10_public.id
    vpc_security_group_ids = [aws_security_group.sg_vpc10_public.id]
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
    ami                    = "ami-0c02fb55956c7d316"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc10_public.id
    vpc_security_group_ids = [aws_security_group.sg_vpc10_public.id]
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
