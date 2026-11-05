resource "aws_subnet" "subnetz-public" {           # public subnet erstellen 
  vpc_id                  = aws_vpc.vpc-brunner.id # der vpc mappen (sonst wird die vpc gar nicht verwendet)
  cidr_block              = "10.0.1.0/24"          # cidr block für das subnet
  availability_zone       = "us-east-1a"           # region des subnet
  map_public_ip_on_launch = true                   # sollen den instances public ips gegeben werden beim start? JA
  tags = {
    Name = "Subnetz-Public" # name
  }
}

resource "aws_subnet" "subnetz-privat" {           # privat subnet erstellen 
  vpc_id                  = aws_vpc.vpc-brunner.id # der vpc mappen (sonst wird die vpc gar nicht verwendet)
  cidr_block              = "10.0.11.0/24"         # cidr block für das subnet
  availability_zone       = "us-east-1a"           # region des subnet
  map_public_ip_on_launch = false                  # sollen den instances public ips gegeben werden beim start? NEIIINN
  tags = {
    Name = "Subnetz-Privat" # name
  }
}