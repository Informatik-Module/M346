terraform {
  required_providers {  #Gibt die benötigten provider an (aws)
    aws = {
      source = "hashicorp/aws"  #Die quelle des providers
    }
  }
}

provider "aws" {
  region = "us-east-1" #die Region des learning labs
}

resource "aws_security_group" "tag3_sg" {  #Erstelle eine security group und vergibt internen namen
  name_prefix = "tag3-"  #OpenTofu erstellt hier hinten eine eindeutige nummer zur identifizierung
  description = "SSH und HTTP fuer Tag 3"

  ingress {
    description = "SSH"
    from_port   = 22  #von port 22 zu port 22 bedeutet dann nur port 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  #von überall
  }

  ingress {
    description = "HTTP"
    from_port   = 80  #von port 80 zu port 80 bedeutet dann nur port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  #von überall
  }

    egress {
    description = "Ausgehend alles erlaubt"
    from_port   = 0  #von port 0 zu port 0 bedeutet zusammen mit protocol -1 alle ports
    to_port     = 0 
    protocol    = "-1"  #Bedeutet alle Protokolle
    cidr_blocks = ["0.0.0.0/0"]  #zu allen zielen
  }

  tags = {
    Name = "SG-Tag3-Mischa"  #Name der Security Group
  }
}

resource "aws_instance" "web" {  #Erstellt die instance und gibt den namen web
  ami = "ami-0d97d7f07b25dd693"  #die ami id (ubuntu 26.04)
  instance_type = "t3.micro"  #den typ der instanz, hier mit einem GiB RAM und 2 vCPUs
  vpc_security_group_ids = [aws_security_group.tag3_sg.id]  #verweist auf die oben erstellte security group per internem namen
  user_data =file("cloud-init-template-sch.yaml")  #verweist auf meine cloud init datei
  user_data_replace_on_change = true  #OpenTofu baut die Instanz neu wenn sich das template ändert

  tags = {  #gibt der instanz den namen tag3 -web
    Name = "Tag3-mischa"
  }
}

output "public_ip" { #gibt die public IP des servers aus
  description = "Oeffentliche IP des servers"
  value       = aws_instance.web.public_ip
}