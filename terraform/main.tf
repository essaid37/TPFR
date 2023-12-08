# provider aws
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

# définition de la région
provider "aws" {
  region = "eu-west-1"
}

# type de clé
resource "tls_private_key" "cle_mhd" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# paire de clé
resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "paire_mhd"
  public_key = tls_private_key.cle_mhd.public_key_openssh
}

resource "aws_vpc" "vpc-mhd" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-mhd"
  }
}

resource "aws_internet_gateway" "igw-mhd" {
  vpc_id = aws_vpc.vpc-mhd.id

  tags = {
    Name = "IGW mhd"
  }
}

resource "local_file" "fichier_paire_cle_ssh" {
  content         = tls_private_key.cle_mhd.private_key_pem
  filename        = "${path.module}/paire_mhd.pem"
  file_permission = "0600"
}

resource "aws_route_table" "rt-mhd" {
  vpc_id = aws_vpc.vpc-mhd.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-mhd.id
  }

  tags = {
    Name = "route table mhd"
  }
}

resource "aws_subnet" "subnet-public-mhd" {
  vpc_id                  = aws_vpc.vpc-mhd.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet mhd"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.subnet-public-mhd.id
  route_table_id = aws_route_table.rt-mhd.id
}

resource "aws_security_group" "sg_mhd" {
  name        = "sg terraform"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.vpc-mhd.id
}

resource "aws_instance" "instance_EC2_terraform" {
  count = 3
  ami           = "ami-0694d931cee176e7d"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet-public-mhd.id

  key_name      = aws_key_pair.ssh_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.sg_mhd.id]

  tags = {
    Name = "serveur-k8s-${count.index}"
  }
}
output "public_ip" {
  value = aws_instance.instance_EC2_terraform.*.public_ip
}