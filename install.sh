#!/bin/sh
sudo -s
yum install -y httpd
service start httpd
service httpd restart
chkconfig httpd on
echo "<html><h1>Hello from damilola ^^</h2></html>" > /var/www/html/index.html
