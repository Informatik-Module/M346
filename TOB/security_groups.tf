resource "aws_security_group" "web_sg" {
  vpc_id      = aws_vpc.vpc-brunner.id            # VPC auch hier angeben sonst geht es nicht mit subnets
  name_prefix = "sg_webserver-"                   # AWS hängt eine Zufallszahl an
  description = "HTTP und SSH fuer den Webserver" # desc
  ingress {                                       # eingehend HTTP erlauben
    from_port   = 80                              # von aussen port 80
    to_port     = 80                              # zu intern port 80
    protocol    = "tcp"                           # nur tcp protokoll (normal bei web traffic)
    cidr_blocks = ["0.0.0.0/0"]                   # von allen ips
  }
  ingress {                     # eingehend SSH erlauben
    from_port   = 22            # 0.0.0.0/0 weil ssh von aussen erreichbar sein soll
    to_port     = 22            # zu internem 22 port (ssh server)
    protocol    = "tcp"         # In einer echten Umgebung gehört hier die
    cidr_blocks = ["0.0.0.0/0"] # eigene IP mit /32 hin.
  }
  egress {                      # ausgehend alles erlauben
    from_port   = 0             # von allen ports
    to_port     = 0             # zu allen ports
    protocol    = "-1"          # auf allen protokollen
    cidr_blocks = ["0.0.0.0/0"] # überall hin
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id      = aws_vpc.vpc-brunner.id               # VPC auch hier angeben sonst geht es nicht mit subnets
  name_prefix = "sg_database-"                       # AWS hängt eine Zufallszahl an
  description = "DB und SSH intern fuer Database"    # desc
  ingress {                                          # eingehend Database erlauben aber nur von webserver
    from_port       = 3306                           # von aussen port 3306
    to_port         = 3306                           # zu intern port 3306
    protocol        = "tcp"                          # nur tcp protokoll (normal bei web traffic)
    security_groups = [aws_security_group.web_sg.id] # nur von der web node security group input erlauben
  }
  # ingress {           # eingehend: SSH
  #   from_port = 22    # 0.0.0.0/0 weil ssh von aussen erreichbar sein soll
  #   to_port   = 22    # zu internem 22 port (ssh server)
  #   protocol  = "tcp" # In einer echten Umgebung gehört hier die
  #   cidr_blocks = [""]    # eigene IP mit /32 hin.
  # }
  egress {                      # ausgehend alles erlauben
    from_port   = 0             # von allen ports
    to_port     = 0             # zu allen ports
    protocol    = "-1"          # auf allen protokollen
    cidr_blocks = ["0.0.0.0/0"] # überall hin
  }
}