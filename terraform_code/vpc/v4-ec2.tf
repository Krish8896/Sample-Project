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
  instance_type = "c7i-flex.large"
  key_name      = "terraform_key" # Replace with your actual key pair name
  # security_groups = [ "demo-aws_security_group" ]
  vpc_security_group_ids = [aws_security_group.demo-aws_security_group.id]
  subnet_id = aws_subnet.my-public-subnet-01.id
  for_each = toset(["jenkins-master", "build-slave", "ansible"])
   tags = {
     Name = "${each.key}"
   }
}

resource "aws_security_group" "demo-aws_security_group" {
  name        = "demo-aws_security_group"
  description = "Allow SSH Access"
  vpc_id      = aws_vpc.my-vpc.id

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

resource "aws_vpc_security_group_ingress_rule" "jenkins-port" {
  security_group_id = aws_security_group.demo-aws_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.demo-aws_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

//* New resource to add VPC and Security Group
resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "my-public-subnet-01" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-north-1a"

  tags = {
    Name = "my_public_subnet-01"
  }
}

resource "aws_subnet" "my-public-subnet-02" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-north-1b"

  tags = {
    Name = "my_public_subnet-02"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    tags = {
        Name = "my_route_table"
    }
}

resource "aws_route_table_association" "rt-assoc-public-subnet-01" {
  subnet_id      = aws_subnet.my-public-subnet-01.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "rt-assoc-public-subnet-02" {
  subnet_id      = aws_subnet.my-public-subnet-02.id
  route_table_id = aws_route_table.route_table.id
}
  
module "sgs" {
    source = "../sg_eks"
    vpc_id =  aws_vpc.my-vpc.id
 }

module "eks" {
       source = "../eks"
       vpc_id = aws_vpc.my-vpc.id
       subnet_ids = [aws_subnet.my-public-subnet-01.id,aws_subnet.my-public-subnet-02.id]
       sg_ids = module.sgs.security_group_public
 }