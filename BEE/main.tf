# Provider: AWS-Plugin laden
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Region vom Learner Lab
provider "aws" {
  region = "us-east-1"
}

# Security Group: rein nur SSH und HTTP, raus alles
resource "aws_security_group" "web_sg" {
  name        = "SG-Tag3-Simon"
  description = "SSH und HTTP erlauben"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -1 = alle Protokolle
  egress {
    description = "Alles raus"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Tag3-Simon"
  }
}

# Instanz mit Ubuntu 26.04, eingerichtet durch cloud-init
resource "aws_instance" "web" {
  ami           = "ami-0d97d7f07b25dd693"
  instance_type = "t3.micro"

  # Verweis auf die SG oben, keine feste ID
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Template als user_data, bei Aenderung Instanz neu bauen
  user_data                   = file("cloud-init-simon.yaml")
  user_data_replace_on_change = true
  tags = {
    Name = "Tag3-Simon"
  }
}

# Oeffentliche IP nach dem apply anzeigen
output "public_ip" {
  value = aws_instance.web.public_ip
}