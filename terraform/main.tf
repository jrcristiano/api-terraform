terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "app" {
  name         = var.ecr_repository_name
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_key_pair" "deploy_key" {
  key_name   = "api-terraform-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_security_group" "ec2_sg" {
  name        = "api-terraform-ec2-sg"
  description = "API server security group"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = length(var.ssh_allowed_cidr) > 0 ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidr
    }
  }

  ingress {
    description = "HTTP"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.ec2_instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.deploy_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "api-terraform-ec2"
  }
}

resource "aws_eip" "app" {
  domain = "vpc"

  tags = {
    Name = "api-terraform-eip"
  }
}

resource "aws_eip_association" "app" {
  instance_id   = aws_instance.app_server.id
  allocation_id = aws_eip.app.id
}

# -- IAM deployer user (programmatic access for CI/CD) --

resource "aws_iam_user" "deployer" {
  name = "api-terraform-deployer"
}

resource "aws_iam_access_key" "deployer" {
  user = aws_iam_user.deployer.name
}

resource "aws_iam_policy" "deployer" {
  name = "api-terraform-deployer-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "deployer" {
  user       = aws_iam_user.deployer.name
  policy_arn = aws_iam_policy.deployer.arn
}

# -- Data sources --

data "aws_vpc" "default" {
  default = true
}

data "aws_ec2_instance_type_offerings" "app" {
  filter {
    name   = "instance-type"
    values = [var.ec2_instance_type]
  }

  location_type = "availability-zone"
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.app.locations
  }
}

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

output "public_ip" {
  description = "Elastic IP of the EC2 instance"
  value       = aws_eip.app.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "deployer_access_key_id" {
  description = "Access key ID for the deployer IAM user"
  value       = aws_iam_access_key.deployer.id
  sensitive   = true
}

output "deployer_secret_access_key" {
  description = "Secret access key for the deployer IAM user"
  value       = aws_iam_access_key.deployer.secret
  sensitive   = true
}
