# wordpress

Step 1: Set up a Virtual Private Server (VPS)

Provisioning a VPS server for jenkins and to host a wordpress site

**Jenkins Server:**
<img width="271" alt="image" src="https://github.com/user-attachments/assets/eb6532e8-f42d-4f37-840f-9dc52bffa930" />

**Wordpress Server:**
<img width="218" alt="image" src="https://github.com/user-attachments/assets/d87f5d4f-eed3-4e76-96bf-0c83a8f2816e" />




**We can Implement modules and re-use the template again, for time-being I have hard-coded the values.**

**Step 2: Install the LEMP Stack**


**Installing the Nginx Web Server**
>>
sudo apt install nginx
>>


If you have the ufw firewall running, allow nginx

**SQL Configuration**

>>
sudo apt install mysql-server
>>
>>
sudo mysql_secure_installation
>>
Answer 'yes' to all of the questions, and choose '2' as the required password strength

sudo mysql

>>
CREATE DATABASE wordpress_db;
CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'P@55word';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
>>



**Installing PHP and Configuring Nginx to Use the PHP **

sudo apt install php-fpm php-mysql

sudo nano /etc/nginx/sites-available/<your_domain>


>>
server {
    listen 80;
    server_name kopsakvp.site www.kopsakvp.site;

    root /var/www/kopsakvp.site;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ .php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
>>


sudo ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/

check configuration by running nginx -t

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

**If you get the message "Unable to write to wp-config.php file":

create the file in the /var/www/html folder:**

sudo nano wp-config.php

<img width="1466" alt="image" src="https://github.com/user-attachments/assets/7e632d07-f495-4c52-9124-a7f6a8d40361" />

**Implementing Security Best Practices**

Enable a Firewall:
>>
sudo ufw allow 'Nginx Full'
sudo ufw enable
>>


**Install SSL with Let's Encrypt:**
>>
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your_domain
sudo systemctl reload nginx
>>

<img width="1649" alt="image" src="https://github.com/user-attachments/assets/8f6feadb-cb8b-4d24-b2c6-beeb62f1d658" />


**Integrating Jenkins for CICD instead of Github actions**


>>
WordPress code is stored in a Git repository.
need SSH access to the remote server where the WordPress site is hosted.
Nginx, MySQL, and PHP are already installed and configured on the remote server.
Jenkins server has the necessary credentials and plugins installed (e.g., Git, SSH Agent).
>>


code snippet:

>>
pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/yourusername/your-wordpress-repo.git' // Replace with your WordPress repository
        BRANCH = 'main' // Replace with the branch you want to deploy
        REMOTE_SERVER = 'your.server.ip' // Replace with your server's IP or hostname
        REMOTE_USER = 'youruser' // Replace with your SSH username
        REMOTE_PATH = '/var/www/wordpress' // Path where WordPress is hosted
        SSH_CREDENTIALS_ID = 'your-ssh-credential-id' // Jenkins credential ID for SSH
    }

    stages {
        stage('Clone Repository') {
            steps {
                echo "Cloning WordPress repository..."
                git branch: "${BRANCH}", url: "${REPO_URL}"
            }
        }

        stage('Build & Test') {
            steps {
                echo "Running basic tests..."
                // Add any WordPress-related tests here if applicable
                sh '''
                php -l wp-config.php # Syntax check for PHP files
                echo "Tests passed!"
                '''
            }
        }

        stage('Deploy to Server') {
            steps {
                echo "Deploying WordPress to remote server..."
                sshagent([SSH_CREDENTIALS_ID]) {
                    sh '''
                    # Sync WordPress files to the remote server
                    rsync -avz --delete ./ ${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH}

                    # Set correct permissions
                    ssh ${REMOTE_USER}@${REMOTE_SERVER} "sudo chown -R www-data:www-data ${REMOTE_PATH} && sudo chmod -R 755 ${REMOTE_PATH}"

                    # Restart Nginx to apply changes
                    ssh ${REMOTE_USER}@${REMOTE_SERVER} "sudo systemctl restart nginx"
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Verifying deployment..."
                sshagent([SSH_CREDENTIALS_ID]) {
                    sh '''
                    # Check if the WordPress site is reachable
                    STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}" http://${REMOTE_SERVER})
                    if [ "$STATUS_CODE" -eq 200 ]; then
                        echo "Deployment successful! WordPress is live."
                    else
                        echo "Deployment failed. HTTP Status Code: $STATUS_CODE"
                        exit 1
                    fi
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Deployment pipeline completed successfully!"
        }
        failure {
            echo "Deployment pipeline failed. Please check the logs."
        }
    }
}

>>


Jenkins file process
1)Clones the WordPress repository from Git into the Jenkins workspace
2)Runs basic syntax checks for PHP files
3)Uses rsync to synchronize WordPress files from Jenkins to the remote server.
4)Corrects file permissions to avoid issues with Nginx and WordPress & restarts nginx.
5)Uses curl to check if the WordPress site is reachable

**Note the Credential ID (used as SSH_CREDENTIALS_ID).**






