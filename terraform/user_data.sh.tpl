#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io docker-compose-v2 unzip

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

# Install AWS CLI v2 (not available as apt package on Noble)
if ! command -v aws &>/dev/null; then
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

cat > /home/ubuntu/nginx.conf <<'NGINXEOF'
server {
    listen 80;

    location / {
        proxy_pass http://api:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINXEOF

cat > /home/ubuntu/docker-compose.yml <<'COMPOSEEOF'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "${port}:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - api
    restart: unless-stopped

  api:
    image: "${ecr_repository}:latest"
    environment:
      - PORT=3000
    restart: unless-stopped
COMPOSEEOF

chown ubuntu:ubuntu /home/ubuntu/nginx.conf /home/ubuntu/docker-compose.yml

su - ubuntu -c "docker login -u AWS -p \$(aws ecr get-login-password --region ${aws_region}) ${ecr_repository}"
su - ubuntu -c "cd /home/ubuntu && docker compose pull"
su - ubuntu -c "cd /home/ubuntu && docker compose up -d"
