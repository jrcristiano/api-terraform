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

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Application port exposed on EC2"
  type        = number
  default     = 3000
}
