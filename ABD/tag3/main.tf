terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"                  # Das Learner Lab läuft in us-east-1
}

resource "aws_security_group" "web_sg" {
  name_prefix = "webserver-"         # AWS haengt eine Zufallszahl an
  description = "HTTP und SSH fuer den Webserver"

  ingress {                             # eingehend: HTTP für alle
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {                             # eingehend: SSH
    from_port   = 22                    # 0.0.0.0/0 ist hier bewusst gewählt
    to_port     = 22                  
    protocol    = "tcp"                 # In einer echten Umgebung gehört hier die
    cidr_blocks = ["0.0.0.0/0"]         # eigene IP mit /32 hin.
  }

  egress {                              # ausgehend: alles erlaubt
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-0d97d7f07b25dd693" # Ubuntu 26.04
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  user_data                   = file("cloud-init-template-ABD.yaml")


  tags = {
    Name = "SG-Tag3-Abdiji"
  }
}

output "public_ip" {                    # Nach dem apply anzeigen
  value = aws_instance.web.public_ip
}
 