resource "aws_instance" "brunner-db" {
  ami                         = "ami-0b6d9d3d33ba97d99"       # Ubuntu 26.04
  instance_type               = "t3.micro"                    # micro instance
  vpc_security_group_ids      = [aws_security_group.db_sg.id] # dynamischer wert
  user_data                   = file("./cloud-init.db.yaml")  # cloud-init für web
  user_data_replace_on_change = true                          # wenn sich die cloud-init ändert, node zerstören und neu erstellen
  subnet_id                   = aws_subnet.subnetz-privat.id  # subnet definiere, welches zu benutzen ist
  tags = {
    Name = "Brunner Datenbank" # name im GUI / web interface
  }
}

resource "aws_instance" "brunner-web" {
  depends_on                  = [aws_instance.brunner-db]      # node BRAUCHT die database
  ami                         = "ami-0b6d9d3d33ba97d99"        # Ubuntu 26.04
  instance_type               = "t3.micro"                     # micro instance
  vpc_security_group_ids      = [aws_security_group.web_sg.id] # dynamischer wert
  user_data                   = file("./cloud-init.web.yaml")  # cloud-init für web
  user_data_replace_on_change = true                           # Nur temporär auf true
  subnet_id                   = aws_subnet.subnetz-public.id   # subnet definiere, welches zu benutzen ist
  tags = {
    Name = "Brunner Webserver" # name im GUI / web interface
  }
}