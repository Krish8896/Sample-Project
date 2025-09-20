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
  security_groups = [ "demo-aws_security_group" ]

  tags = {
    Name = "terraform-demo-server"
  }
}

resource "aws_security_group" "demo-aws_security_group" {
  name        = "demo-aws_security_group"
  description = "Allow SSH Access"
  # vpc_id      = aws_vpc.main.id

  tags = {
    Name = "ssh-port-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_incoming" {
  security_group_id = aws_security_group.demo-aws_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.demo-aws_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}