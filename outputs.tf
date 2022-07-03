output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the Instance"
}

output "public_dns" {
  value       = aws_instance.example.public_dns
  description = "The Public dns of the Instance"
}

output "private_ip" {
  value       = aws_instance.example.private_ip
  description = "The Private_ip of the Instance"
}
