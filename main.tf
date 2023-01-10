provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "carmine_server" {
  ami           = "ami-06878d265978313ca"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.carmine_security_group.id]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hola Terraformers!" > index.html
                nohup busybox httpd -f -p 8080
                EOF

  tags = {
    Name = "First server"
  }
}

resource "aws_security_group" "carmine_security_group" {
  name = "main-server"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Public access from 8080 port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
  }
}
