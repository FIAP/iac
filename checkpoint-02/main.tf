terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Região
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "vpc10" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "vpc10"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw_vpc10" {
  vpc_id = aws_vpc.vpc10.id

  tags = {
    "Name" = "igw_vpc10"
  }
}

# Subnet's
resource "aws_subnet" "sn_vpc10_pub_1a" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "sn_vpc10_pub_1a"
  }
}

resource "aws_subnet" "sn_vpc10_pub_1c" {
  vpc_id                  = aws_vpc.vpc10.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"

  tags = {
    "Name" = "sn_vpc10_pub_1c"
  }
}

resource "aws_subnet" "sn_vpc10_priv_1a" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "sn_vpc10_priv_1a"
  }
}

resource "aws_subnet" "sn_vpc10_priv_1c" {
  vpc_id            = aws_vpc.vpc10.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1c"

  tags = {
    "Name" = "sn_vpc10_priv_1c"
  }
}

# Elastic IP
resource "aws_eip" "eip_1" {
  depends_on = [aws_internet_gateway.igw_vpc10]
  vpc        = true

  tags = {
    "Name" = "eip_pub_1a"
  }
}

resource "aws_eip" "eip_2" {
  depends_on = [aws_internet_gateway.igw_vpc10]
  vpc        = true

  tags = {
    "Name" = "eip_pub_1c"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "ngw_pub_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.sn_vpc10_pub_1a.id
  depends_on    = [aws_internet_gateway.igw_vpc10]

  tags = {
    "Name" = "ngw_pub_1"
  }
}

resource "aws_nat_gateway" "ngw_pub_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.sn_vpc10_pub_1c.id
  depends_on    = [aws_internet_gateway.igw_vpc10]

  tags = {
    "Name" = "ngw_pub_2"
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
    "Name" = "rt_pub"
  }
}

resource "aws_route_table" "rt_pub_1c" {
  vpc_id = aws_vpc.vpc10.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc10.id
  }

  tags = {
    "Name" = "rt_pub_1c"
  }
}

resource "aws_route_table" "rt_priv_1a" {
  vpc_id = aws_vpc.vpc10.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_pub_1.id
  }

  tags = {
    "Name" = "rt_priv_1a"
  }
}

resource "aws_route_table" "rt_priv_1c" {
  vpc_id = aws_vpc.vpc10.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_pub_2.id
  }

  tags = {
    "Name" = "rt_priv_1c"
  }
}

# Associando a route table
resource "aws_route_table_association" "rta_pub_1a" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1a.id
  route_table_id = aws_route_table.rt_pub.id
}

resource "aws_route_table_association" "rta_pub_1c" {
  subnet_id      = aws_subnet.sn_vpc10_pub_1c.id
  route_table_id = aws_route_table.rt_pub_1c.id
}

resource "aws_route_table_association" "rta_priv_1a" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1a.id
  route_table_id = aws_route_table.rt_priv_1a.id
}

resource "aws_route_table_association" "rta_priv_1c" {
  subnet_id      = aws_subnet.sn_vpc10_priv_1c.id
  route_table_id = aws_route_table.rt_priv_1c.id
}


# Security Group
resource "aws_security_group" "asg_ws" {
  name        = "sg_instance"
  description = "Security Group das instancias EC2"
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
    "Name" = "asg_ws"
  }
}

resource "aws_security_group" "asg_rds" {
  name        = "sg_rds"
  description = "Security Group dos bancos de dados"
  vpc_id      = aws_vpc.vpc10.id

  egress {
    description = "All to all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Liberando entrada das EC2 Webserver"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
  }

  ingress {
    description = "All from 10.0.0.0/16"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "asg_rds"
  }
}

# Instâncias EC2
resource "aws_instance" "ws_1" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sn_vpc10_pub_1a.id
  vpc_security_group_ids = [aws_security_group.asg_ws.id]
  user_data              = <<-EOF
#!/bin/bash
# Update with latest packages
yum update -y
# Install Apache
yum install -y httpd mysql php php-mysql php-mysqlnd php-pdo telnet tree git
# Enable Apache service to start after reboot
sudo systemctl enable httpd
# Config connect to DB
cat <<EOT >> /var/www/config.php
<?php
define('DB_SERVER', 'DB_SERVER');
define('DB_USERNAME', 'DB_USERNAME');
define('DB_PASSWORD', 'DB_PASSWORD');
define('DB_DATABASE', 'DB_DATABASE');
?>
EOT
# Install application
cd /tmp
git clone https://github.com/kledsonhugo/notifier
cp /tmp/notifier/public/index.php /var/www/html/
# Start Apache service
service httpd restart
EOF

  tags = {
    "Name" = "ws_1"
  }
}

resource "aws_instance" "ws_2" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sn_vpc10_pub_1a.id
  vpc_security_group_ids = [aws_security_group.asg_ws.id]
  user_data              = <<-EOF
#!/bin/bash
# Update with latest packages
yum update -y
# Install Apache
yum install -y httpd mysql php php-mysql php-mysqlnd php-pdo telnet tree git
# Enable Apache service to start after reboot
sudo systemctl enable httpd
# Config connect to DB
cat <<EOT >> /var/www/config.php
<?php
define('DB_SERVER', 'DB_SERVER');
define('DB_USERNAME', 'DB_USERNAME');
define('DB_PASSWORD', 'DB_PASSWORD');
define('DB_DATABASE', 'DB_DATABASE');
?>
EOT
# Install application
cd /tmp
git clone https://github.com/kledsonhugo/notifier
cp /tmp/notifier/public/index.php /var/www/html/
# Start Apache service
service httpd restart
EOF

  tags = {
    "Name" = "ws_2"
  }
}

resource "aws_instance" "ws_3" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sn_vpc10_pub_1c.id
  vpc_security_group_ids = [aws_security_group.asg_ws.id]
  user_data              = <<-EOF
#!/bin/bash
# Update with latest packages
yum update -y
# Install Apache
yum install -y httpd mysql php php-mysql php-mysqlnd php-pdo telnet tree git
# Enable Apache service to start after reboot
sudo systemctl enable httpd
# Config connect to DB
cat <<EOT >> /var/www/config.php
<?php
define('DB_SERVER', 'DB_SERVER');
define('DB_USERNAME', 'DB_USERNAME');
define('DB_PASSWORD', 'DB_PASSWORD');
define('DB_DATABASE', 'DB_DATABASE');
?>
EOT
# Install application
cd /tmp
git clone https://github.com/kledsonhugo/notifier
cp /tmp/notifier/public/index.php /var/www/html/
# Start Apache service
service httpd restart
EOF

  tags = {
    "Name" = "ws_3"
  }
}

resource "aws_instance" "ws_4" {
  ami                    = "ami-02e136e904f3da870"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sn_vpc10_pub_1c.id
  vpc_security_group_ids = [aws_security_group.asg_ws.id]
  user_data              = <<-EOF
#!/bin/bash
# Update with latest packages
yum update -y
# Install Apache
yum install -y httpd mysql php php-mysql php-mysqlnd php-pdo telnet tree git
# Enable Apache service to start after reboot
sudo systemctl enable httpd
# Config connect to DB
cat <<EOT >> /var/www/config.php
<?php
define('DB_SERVER', 'DB_SERVER');
define('DB_USERNAME', 'DB_USERNAME');
define('DB_PASSWORD', 'DB_PASSWORD');
define('DB_DATABASE', 'DB_DATABASE');
?>
EOT
# Install application
cd /tmp
git clone https://github.com/kledsonhugo/notifier
cp /tmp/notifier/public/index.php /var/www/html/
# Start Apache service
service httpd restart
EOF

  tags = {
    "Name" = "ws_4"
  }
}

# SNS
resource "aws_sns_topic" "sns_app" {
  name = "sns_app"

  tags = {
    "Name" = "sns_app"
  }
}

resource "aws_sns_topic_subscription" "sns_notificacao" {
  topic_arn = aws_sns_topic.sns_app.arn
  protocol  = "email"                 # Poderia ser SMS, neste caso o endpoint abaixo seria o número de telefone do usuário
  endpoint  = "teste.teste@gmail.com" # Para o checkpoint coloquei um email genérico
}

# VPC End-point
resource "aws_vpc_endpoint" "vpc_ep_vpc10" {
  vpc_id             = aws_vpc.vpc10.id
  service_name       = "com.amazonaws.us-east-1.sns"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.asg_ws.id]

  private_dns_enabled = true

  tags = {
    "Name" = "vpc_ep_vpc10"
  }
}

# Elastic Load Balancer
resource "aws_elb" "elb_ws" {
  name    = "elb-ws"
  subnets = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = [aws_instance.ws_1.id, aws_instance.ws_2.id, aws_instance.ws_3.id, aws_instance.ws_4.id]

  tags = {
    "Name" = "elb_ws"
  }
}

# BD RDS Sincronizado
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = [aws_subnet.sn_vpc10_pub_1a.id, aws_subnet.sn_vpc10_pub_1c.id]

  tags = {
    "Name" = "db_subnet"
  }
}

resource "aws_db_instance" "db_rds" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "dbrds"
  username               = "db_admin"
  password               = "pass_db_rds"
  parameter_group_name   = "default.mysql5.7"
  storage_type           = "gp2"
  multi_az               = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.asg_rds.id]
  port                   = 3306

  tags = {
    "Name" = "db_rds"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.db_rds.endpoint
} 