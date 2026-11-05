terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-*-26.04-amd64-server-*"]
  }
}

resource "aws_vpc" "brunner" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-Brunner"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.brunner.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnetz-Public"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.brunner.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Subnetz-Private"
  }
}

resource "aws_internet_gateway" "brunner" {
  vpc_id = aws_vpc.brunner.id

  tags = {
    Name = "IGW-Brunner"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "EIP-NAT"
  }
}

resource "aws_eip" "web" {
  domain = "vpc"

  tags = {
    Name = "EIP-Web"
  }
}

resource "aws_nat_gateway" "brunner" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT-Brunner"
  }

  depends_on = [aws_internet_gateway.brunner]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.brunner.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.brunner.id
  }

  tags = {
    Name = "RT-Public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.brunner.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.brunner.id
  }

  tags = {
    Name = "RT-Private"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "web" {
  name   = "SG-Web"
  vpc_id = aws_vpc.brunner.id

  tags = {
    Name = "SG-Web"
  }
}

resource "aws_security_group" "db" {
  name   = "SG-DB"
  vpc_id = aws_vpc.brunner.id

  tags = {
    Name = "SG-DB"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_alles" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "db_ssh" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "db_mysql" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "db_alles" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  private_ip             = "10.0.1.10"
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data                   = file("cloud-init-tag2.yaml")
  user_data_replace_on_change = true

  tags = {
    Name = "Brunner-Web"
  }

  depends_on = [aws_internet_gateway.brunner]
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  private_ip             = "10.0.11.20"
  vpc_security_group_ids = [aws_security_group.db.id]

  user_data                   = file("Cloud-init-db.yaml")
  user_data_replace_on_change = true

  tags = {
    Name = "Brunner-DB"
  }

  depends_on = [aws_nat_gateway.brunner]
}

resource "aws_eip_association" "web" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}

output "web_elastic_ip" {
  value = aws_eip.web.public_ip
}

output "web_private_ip" {
  value = aws_instance.web.private_ip
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}