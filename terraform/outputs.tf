output "webserver" {
  value       = aws_instance.webserver.public_ip
  description = "The address of the webserver"
}

output "proxysql" {
  value       = aws_instance.proxysql.public_ip
  description = "The address of the webserver"
}