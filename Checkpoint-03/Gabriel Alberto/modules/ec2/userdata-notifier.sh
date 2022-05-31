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
define('DB_SERVER', '${rds_endpoint}');
define('DB_USERNAME', '${rds_user}');
define('DB_PASSWORD', '${rds_password}');
define('DB_DATABASE', '${rds_name}');
?>
EOT

# Install application
cd /tmp
git clone https://github.com/kledsonhugo/notifier
cp /tmp/notifier/public/index.php /var/www/html/

# Start Apache service
service httpd restart