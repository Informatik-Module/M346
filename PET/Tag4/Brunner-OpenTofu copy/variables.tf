# AWS region where the VPC, networking, and instances are created.
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# Availability Zone used by both subnets; it must be available to the account.
variable "availability_zone" {
  description = "Availability Zone; your AWS account must be able to use it"
  type        = string
  default     = "us-east-1a"
}

# OpenSSH public key installed for SSH access. Never put a private key here.
variable "ssh_public_key" {
  description = "Contents of your PERSONAL SSH public key (ssh-ed25519 ... or ssh-rsa ...). Not your private key!"
  type        = string
  sensitive   = true
  # Reject values that do not look like an OpenSSH public key.
  validation {
    condition     = can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-[^ ]+) [A-Za-z0-9+/=]+", var.ssh_public_key))
    error_message = "Provide a valid SSH public key, such as ssh-ed25519 AAAA..."
  }
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyZQupD9kYDE5Ddk3T75qv6+/cWf5hhGCDdpaVoiVl9BZIayxiLvA8tA+bp2mF5ZVitnDMskvvkd1fBCYrql+dzktQ0uDmHKv6OZgKSVRJjKRf0bfYX6W1KyIglq9ZPNq5rV8I9UpBZALfIfAaAvtKB2mw4n+EHKCWcJh/oV4jFgjNEqokhIveIAAHqxvgRzEOCLNQDGd7k7GFg9URmWZBLiNCZziO7AfuOrAImZpNwTS9QczmEQjtnJMrwQkBhPtMteqS5fiHJpg5KFT63Xu2rSV8zwCyicn6SNxUgJ3CZNEpreHbyRBd0gw7pugK4WYLq8p1lgQaAGAiJNs5s0Al # Adam's SSH public key."
}

# IPv4 CIDR range permitted to SSH into the web server.
variable "web_ssh_cidr" {
  description = "Allowed SSH IPv4 CIDR for web server. The exercise requests 0.0.0.0/0; restrict to your IP/32 for real deployments."
  type        = string
  default     = "0.0.0.0/0"
}
