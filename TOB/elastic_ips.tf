resource "aws_eip" "web_elastic-ip" { # WEB NODE | ELASTIC IP (eip) erstellen
  domain = "vpc"                      # sagt AWS, für welche netzwerkumgebung die Elastic IP reserviert werden soll
  tags = {
    Name = "Web Elastic IP" # eip = elastic ip
  }
}
resource "aws_eip_association" "web_elastic-ip_zuweisung" { # ELASTIC IP (eip) einer instance zuweisen
  instance_id   = aws_instance.brunner-web.id               # welche EC2 instance bekommt die ELASTIC IP (eip)
  allocation_id = aws_eip.web_elastic-ip.id                 # id der ELASTIC IP (eip)
}

resource "aws_eip" "nat_elastic-ip" { # NAT GATEWAY | ELASTIC IP (eip) erstellen 
  domain = "vpc"                      # sagt AWS, für welche netzwerkumgebung die Elastic IP reserviert werden soll 
  tags = {
    Name = "NAT Elastic IP" # eip = elastic ip
  }
}