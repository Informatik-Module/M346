# /usr/bin/tofu apply -auto-approve -show-sensitive -compact-warnings
terraform {
  required_providers { aws = { source = "hashicorp/aws" } }
}

provider "aws" {
  region                   = "us-east-1"                # Learner Lab läuft auf us-east-1
  shared_credentials_files = ["../../.aws_credentials"] # meine super geheimen login-daten shhhh~
}

resource "aws_vpc" "vpc-brunner" {
  cidr_block           = "10.0.0.0/16" # cidr block
  enable_dns_hostnames = true          # JA zu hostname-dns!
  enable_dns_support   = true          # jetzt muss dns nur noch supportet sein: 
  instance_tenancy     = "default"     # macht irgendwie, dass EC2 immer das nutzen? nicht ganz sicher;; https://search.opentofu.org/provider/hashicorp/aws/latest/docs/resources/vpc#attr-instance_tenancy
  # ipv6_cidr_block      = "0"           # KEIN IPv6! Ewww (default)
  tags = {
    "Name" = "VPC-Brunner"
  }
}