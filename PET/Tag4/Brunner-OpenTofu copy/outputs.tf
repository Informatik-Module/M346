# Print the stable public IP assigned to the web server.
output "web_elastic_ip" {
  description = "Permanent public IPv4 of Brunner-Web"
  value       = aws_eip.web.public_ip
}

# Provide a browser-ready URL for the web server.
output "web_url" {
  value = "http://${aws_eip.web.public_ip}"
}

# Show the SSH command template; replace the placeholder with your private-key path.
output "ssh_command" {
  value = "ssh -i PATH_TO_YOUR_PRIVATE_KEY brunner@${aws_eip.web.public_ip}"
}

# Show the web server's private address inside the VPC.
output "web_private_ip" {
  value = aws_instance.web.private_ip
}

# Show the database server's private address inside the VPC.
output "db_private_ip" {
  value = aws_instance.db.private_ip
}

# Show the public IP used by the NAT gateway.
output "nat_elastic_ip" {
  value = aws_eip.nat.public_ip
}

# Show the AWS identifier of the web server instance.
output "web_instance_id" {
  value = aws_instance.web.id
}

# Show the AWS identifier of the database server instance.
output "db_instance_id" {
  value = aws_instance.db.id
}
