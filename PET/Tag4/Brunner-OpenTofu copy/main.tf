# Configure the AWS provider using the region selected in variables.tf.
provider "aws" {
  region = var.aws_region
}

# Resolve Canonical's current Ubuntu 26.04 LTS AMD64 image ID for this region.
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/26.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# Create the VPC that contains both Brunner server subnets.
resource "aws_vpc" "brunner" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "VPC-Brunner" }
}

# Create the public subnet for the web server and NAT gateway.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.brunner.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags                    = { Name = "Subnetz-Public" }
}

# Create the private subnet for the database server.
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.brunner.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags                    = { Name = "Subnetz-Private" }
}

# Attach the VPC to the Internet so resources in the public subnet can use it.
resource "aws_internet_gateway" "brunner" {
  vpc_id = aws_vpc.brunner.id
  tags   = { Name = "IGW-Brunner" }
}

# Allocate a public IP address for the NAT gateway.
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "EIP-NAT-Brunner" }
}

# Let private-subnet instances access the Internet through this public NAT gateway.
resource "aws_nat_gateway" "brunner" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.brunner]
  tags          = { Name = "NAT-Brunner" }
}

# Define routing for the public subnet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.brunner.id
  tags   = { Name = "RT-Public" }
}

# Send public-subnet Internet-bound traffic to the Internet Gateway.
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.brunner.id
}

# Associate the public subnet with its Internet Gateway route table.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Define routing for the private subnet.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.brunner.id
  tags   = { Name = "RT-Private" }
}

# Send private-subnet Internet-bound traffic through the NAT gateway.
resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.brunner.id
}

# Associate the private subnet with its NAT route table.
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Create the web server's security group; its ingress rules are defined below.
resource "aws_security_group" "web" {
  name        = "SG-Web"
  description = "Web server: HTTP and SSH"
  vpc_id      = aws_vpc.brunner.id
  tags        = { Name = "SG-Web" }
}

# Create the database security group. Its only ingress rules are TCP 22 and
# TCP 3306, and both accept connections only from instances in SG-Web.
resource "aws_security_group" "db" {
  name        = "SG-DB"
  description = "Database: SSH and MySQL only from SG-Web"
  vpc_id      = aws_vpc.brunner.id

  ingress {
    description     = "SSH from web server SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    description     = "MySQL from web server SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  tags = { Name = "SG-DB" }
}

# Allow HTTP requests from any IPv4 address to the web server.
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "HTTP from Internet"
}

# Allow SSH to the web server only from the configured source CIDR.
resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = var.web_ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "SSH to web server"
}

# Allow the web server to make outbound IPv4 connections.
resource "aws_vpc_security_group_egress_rule" "web_out" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All outbound IPv4"
}

# Allow the database to make outbound IPv4 connections, including through NAT.
resource "aws_vpc_security_group_egress_rule" "db_out" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All outbound IPv4 (via NAT)"
}

# Launch the public web server with the configured cloud-init template.
resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  private_ip                  = "10.0.1.10"
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/cloud-init-web.yaml.tftpl", {
    ssh_public_key = var.ssh_public_key
  })
  user_data_replace_on_change = true
  # Wait for the Internet route before cloud-init downloads Apache packages.
  depends_on = [aws_route.public_internet, aws_route_table_association.public]
  tags       = { Name = "Brunner-Web" }
}

# Give the web server a stable public IPv4 address.
resource "aws_eip" "web" {
  domain   = "vpc"
  instance = aws_instance.web.id
  tags     = { Name = "EIP-Brunner-Web" }
}

# Launch the database server without a public IP in the private subnet.
resource "aws_instance" "db" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  private_ip                  = "10.0.11.20"
  vpc_security_group_ids      = [aws_security_group.db.id]
  associate_public_ip_address = false
  user_data = templatefile("${path.module}/cloud-init-db.yaml.tftpl", {
    ssh_public_key = var.ssh_public_key
  })
  user_data_replace_on_change = true
  # Ensure the NAT gateway and private route exist before cloud-init installs
  # the database packages.
  depends_on = [aws_route.private_internet, aws_route_table_association.private]
  tags       = { Name = "Brunner-DB" }
}
