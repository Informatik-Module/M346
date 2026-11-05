terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "meine_ip" {
  type = string
}

resource "aws_security_group" "web_sg" {
  name_prefix = "webserver-"
  description = "HTTP und SSH fuer den Webserver"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.meine_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Tag3-Nick"
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-0d97d7f07b25dd693"
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  user_data                   = file("cloud-init-tag2.yaml")
  user_data_replace_on_change = true

  tags = {
    Name = "Tag3-Nick-tofu-geaendert"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}