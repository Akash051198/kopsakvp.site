#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo apt install mysql-server -y
sudo apt install php-fpm php-mysql php-cli php-curl php-gd php-mbstring -y
