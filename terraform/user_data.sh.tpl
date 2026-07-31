#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io docker-compose git

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

cat > /home/ubuntu/docker-compose.yml <<'EOF'
version: '3.9'
services:
  api:
    image: "${ecr_repository}:latest"
    ports:
      - "${port}:${port}"
    restart: unless-stopped
EOF

chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml

su - ubuntu -c "docker login -u AWS -p \$(aws ecr get-login-password --region ${aws_region}) ${ecr_repository}"
su - ubuntu -c "cd /home/ubuntu && docker-compose pull"
su - ubuntu -c "cd /home/ubuntu && docker-compose up -d"
