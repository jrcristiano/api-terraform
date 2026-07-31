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
su - ubuntu -c "cd /home/ubuntu && docker compose pull"
su - ubuntu -c "cd /home/ubuntu && docker compose up -d"
