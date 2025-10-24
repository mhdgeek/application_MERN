output "public_ip" {
  description = "Public IP de l'EC2"
  value       = aws_instance.app_server.public_ip
}
