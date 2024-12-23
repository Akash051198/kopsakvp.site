# wordpress

Step 1: Set up a Virtual Private Server (VPS)

Provisioning a VPS server for jenkins and to host a wordpress site

**Jenkins Server:**
<img width="271" alt="image" src="https://github.com/user-attachments/assets/eb6532e8-f42d-4f37-840f-9dc52bffa930" />

**Wordpress Server:**
<img width="218" alt="image" src="https://github.com/user-attachments/assets/d87f5d4f-eed3-4e76-96bf-0c83a8f2816e" />

**We can Implement modules and re-use the template again, for time-being I have hard-coded the values.**

Step 2: Install the LEMP Stack

**PHP, MySQL and Nginx installation**

>> sudo apt install php-fpm php-mysql mysql-server nginx unzip -y

**Configuring Nginx to work with PHP**

replace Nginx's 'default' configuration

>>
cd /etc/nginx/sites-available
sudo rm default
sudo nano default
>>

paste in the following configuration to the newly created empty file:

>>
server {
    listen 80;
    server_name your_server_domain_or_IP;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ .php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
>

restart Nginx for the new configuration

sudo systemctl restart nginx

**Downloading Wordpress to the Ubuntu server**

Download files /var/www/html folder

>>sudo wget https://wordpress.org/latest.zip

Extracting the contents of the Wordpress archive

>>sudo unzip latest.zip

WordPress to the server's root folder

>>sudo mv wordpress/* .

Changing the owner of the Wordpress files

>>sudo chown -R www-data:www-data *

**Securing MySQL installation**

sudo mysql

>>
CREATE DATABASE wordpress_db;
CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'P@55word';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
>>

**If you get the message "Unable to write to wp-config.php file":

create the file in the /var/www/html folder:**

sudo nano wp-config.php

<img width="1466" alt="image" src="https://github.com/user-attachments/assets/7e632d07-f495-4c52-9124-a7f6a8d40361" />









