#!/bin/bash

# Exit if any command fails
set -e

echo "Updating system..."
sudo apt update -y

echo "Installing dependencies..."
sudo apt install -y git curl apt-transport-https ca-certificates software-properties-common

echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt install -y docker-ce docker-ce-cli containerd.io

echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Cloning repository..."
git clone https://github.com/arkh91/outline-web-manager.git
cd outline-web-manager

echo "Setting up environment..."
cp .env.dist .env.local

# Generate new APP_SECRET
APP_SECRET=$(openssl rand -hex 20)
echo "Generated APP_SECRET: $APP_SECRET"

# Remove any existing APP_SECRET line
sed -i '/^APP_SECRET=/d' .env.local

# Append the new APP_SECRET
echo "APP_SECRET=$APP_SECRET" >> .env.local


echo "Starting Docker containers..."
sudo docker-compose up -d

echo "Setup complete!"
echo
echo "You can access it via:"
echo "Open http://localhost:8086/admin"
echo "Email: user@email.local"
echo "Password: 123456"

#bash <(curl -Ls https://raw.githubusercontent.com/arkh91/outline-web-manager/refs/heads/master/installer.sh)
