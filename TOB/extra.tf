resource "aws_nat_gateway" "nat-brunner" {     # NAT gateway erstellen
  allocation_id = aws_eip.nat_elastic-ip.id    # was ist die id der asoziierten elastic id?
  subnet_id     = aws_subnet.subnetz-public.id # was ist die id des subnet?
  tags = {                                     # tags wie name
    Name = "NAT Gateway Brunner"               # nametag
  }
  depends_on = [                     # aws internet gateway muss laufen, sonst kommt nat auch nicht raus
    aws_internet_gateway.igw-brunner # hier die instance angeben, auf welche es angewiesen ist
  ]
}

resource "aws_internet_gateway" "igw-brunner" { # INTERNET GATEWAYhier definieren wir den 
  vpc_id = aws_vpc.vpc-brunner.id
  tags = {
    Name = "Internet Gateway Brunner"
  }
}