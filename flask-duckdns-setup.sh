#!/bin/bash

# Variables (to be set before running the script)
DUCKDNS_SUBDOMAIN=""
DUCKDNS_TOKEN=""
FLASK_APP_NAME=""
FLASK_APP_DIR=""
USER=""
VENV_PATH=""
EMAIL=""

# Install dependencies
# Update system and install dependencies
sudo apt-get update
sudo apt-get install -y curl nginx certbot python3-certbot-nginx

# Set up DuckDNS to periodically update the IP address 
# (You can comment this out if you are on a dedicated IP address)
mkdir -p ~/duckdns
echo "echo url=\"https://www.duckdns.org/update?domains=${DUCKDNS_SUBDOMAIN}&token=${DUCKDNS_TOKEN}&ip=\" | curl -k -o ~/duckdns/duck.log -K -" > ~/duckdns/duck.sh
chmod 700 ~/duckdns/duck.sh

# Set up cron job for DuckDNS
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/duckdns/duck.sh") | crontab -

# Configure Nginx (You can change the flask_app to your app name)
cat << EOF | sudo tee /etc/nginx/sites-available/flask_app
server {
    listen 80;
    server_name ${DUCKDNS_SUBDOMAIN}.duckdns.org;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled
sudo nginx -t && sudo systemctl restart nginx

# Configure firewall (Edit these as needed)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw --force enable
sudo ufw reload


# Set up SSL with Let's Encrypt
sudo certbot --nginx -d ${DUCKDNS_SUBDOMAIN}.duckdns.org --non-interactive --agree-tos --email ${EMAIL}


# Set up Flask app service
cat << EOF | sudo tee /etc/systemd/system/flask_app.service
[Unit]
Description=Gunicorn instance to serve flask app
After=network.target

[Service]
User=${USER}
WorkingDirectory=${FLASK_APP_DIR}
ExecStart=${VENV_PATH}/bin/gunicorn -w 4 -b 127.0.0.1:5000 ${FLASK_APP_NAME}:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start flask_app
sudo systemctl enable flask_app

echo "Setup complete! Your Flask app should now be accessible at https://${DUCKDNS_SUBDOMAIN}.duckdns.org"
