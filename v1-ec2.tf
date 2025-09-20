terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "demo-server" {
  ami           = "ami-0a716d3f3b16d290c" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.micro"
    key_name      = "terraform_key" # Replace with your actual key pair name

  tags = {
    Name = "terraform-demo-server"
  }
}