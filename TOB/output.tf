output "elastic-ip_webserver" { # Nach dem apply anzeigen
  value       = aws_instance.brunner-web.public_ip
  description = "public ip of webserver"
}
output "public-ip_database" { # Nach dem apply anzeigen
  value       = aws_instance.brunner-db.public_ip
  description = "public auto ip of database server"
}
output "public_elastic-ip_webserver" { # Nach dem apply anzeigen
  value       = aws_eip.web_elastic-ip.public_ip
  description = "public ip of webserver via Elastic IP"
}
output "elastic-ip_nat-gateway" { # Nach dem apply anzeigen
  value       = aws_nat_gateway.nat-brunner.public_ip
  description = "public ip of nat gateway"
}
output "private-ip_webserver" { # Nach dem apply anzeigen
  value       = aws_instance.brunner-web.private_ip
  description = "private ip of webserver"
}
output "private-ip_database" { # Nach dem apply anzeigen
  value       = aws_instance.brunner-db.private_ip
  description = "private ip of database server"
}
