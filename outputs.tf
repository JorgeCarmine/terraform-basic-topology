output "public_dns_server_1" {
    description = "Public DNS"
    value = "http://${aws_instance.carmine_server_1.public_dns}:8080"
}

output "public_ip_server_1" {
    description = "Public IP"
    value = aws_instance.carmine_server_1.public_ip
}


output "public_dns_server_2" {
    description = "Public DNS"
    value = "http://${aws_instance.carmine_server_2.public_dns}:8080"
}

output "public_ip_server_2" {
    description = "Public IP"
    value = aws_instance.carmine_server_2.public_ip
}

output "dns_load_banacer" {
  description = "DNS público del load balancer"
  value = "https://${aws_lb.carmine_alb.dns_name}"
}
