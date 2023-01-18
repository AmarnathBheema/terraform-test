#!/bin/bash
sudo yum -y install git
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
"echo hello-world" > /var/www/html/index.html
sudo systemctl restart httpd
