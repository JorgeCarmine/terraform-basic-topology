output "public_dns" {
    description = "Public DNS"
    value = "http://${aws_instance.carmine_server.public_dns}"
}

output "public_ip" {
    description = "Public IP"
    value = aws_instance.carmine_server.public_ip
}
