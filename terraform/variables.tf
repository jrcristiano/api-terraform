variable "aws_region" {
  description = "AWS region to deploy"
  type        = string
  default     = "us-east-1"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for EC2 access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_allowed_cidr" {
  description = "CIDR blocks allowed to SSH into the EC2 instance (restrict to your IP or VPN range)"
  type        = list(string)
  default     = [] # empty means no SSH access from internet; provide your IP e.g. ["203.0.113.5/32"]
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "api-terraform"
}

variable "app_port" {
  description = "Application port exposed on EC2"
  type        = number
  default     = 3000
}
