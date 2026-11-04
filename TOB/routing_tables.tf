resource "aws_route_table" "rt-public" {             # route für das public subnet
  vpc_id = aws_vpc.vpc-brunner.id                    # VPC id für welches dieser route table ist
  route {                                            # route source und dest definieren
    cidr_block = "0.0.0.0/0"                         # ALLER traffic über den Internet Gateway routen
    gateway_id = aws_internet_gateway.igw-brunner.id # id des Internet Gateway
  }
  tags = {
    Name = "RT-Public" # name
  }
}
resource "aws_route_table_association" "rta-public" { # ÖFFENTLICH -> IGW | den routing table mit dem subnet zusammen kleben
  subnet_id      = aws_subnet.subnetz-public.id       # id des subnets
  route_table_id = aws_route_table.rt-public.id       # id des routing tables
}


resource "aws_route_table" "rt-privat" {        # route für das privat-subnet
  vpc_id = aws_vpc.vpc-brunner.id               # VPC id für welches dieser route table ist
  route {                                       # route source und dest definieren
    cidr_block = "0.0.0.0/0"                    # ALLER traffic über den NAT Gateway routen
    gateway_id = aws_nat_gateway.nat-brunner.id # id des NAT Gateway
  }
  tags = {
    Name = "RT-Privat" # name
  }
}
resource "aws_route_table_association" "rta-privat" { # PRIVAT -> NAT | den routing table mit dem subnet zusammen kleben
  subnet_id      = aws_subnet.subnetz-privat.id       # id des subnets
  route_table_id = aws_route_table.rt-privat.id       # id des routing tables
}