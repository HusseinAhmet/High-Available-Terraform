#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2.service
systemctl enable apache2.service
echo "<h><head><title> Udacitys School of Cloud Computing</title></head> <body>Hello from Udgram Hussein Ahmed </body> </h>" > /var/www/html/index.html