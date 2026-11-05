
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Default VPC ermitteln
data "aws_vpc" "default" {
  default = true
}

# Aktuelles Ubuntu 24.04 LTS AMI fuer us-east-1 aus dem AMI-Katalog ermitteln
data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Security Group erstellen
resource "aws_security_group" "tag3_sg" {
  name        = "SG-Tag3-Adam"
  description = "Security Group fuer OpenTofu Tag 3"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "SG-Tag3-Adam"
  }
}

# Eingehende SSH-Verbindungen erlauben
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.tag3_sg.id

  description = "SSH Zugriff"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

# Eingehende HTTP-Verbindungen erlauben
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.tag3_sg.id

  description = "HTTP Zugriff"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

# Ausgehenden Datenverkehr erlauben
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.tag3_sg.id

  description = "Gesamter ausgehender Datenverkehr"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Ubuntu-Instanz erstellen und cloud-init als User Data uebergeben
resource "aws_instance" "tag3" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.tag3_sg.id]
  associate_public_ip_address = true

  user_data                   = file("${path.module}/../cloud-init-template-kuerzel.yaml")
  user_data_replace_on_change = true

  tags = {
    Name = "Instance-Tag3-Adam"
  }
}

# Oeffentliche IP-Adresse der Instanz ausgeben
output "public_ip" {
  description = "Oeffentliche IP-Adresse der Ubuntu-Instanz"
  value       = aws_instance.tag3.public_ip
}
