provider "aws" {
  region = "us-east-1"
}

data "aws_subnet" "az_a" {
  availability_zone = "us-east-1a"
}

data "aws_subnet" "az_b" {
  availability_zone = "us-east-1b"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "carmine_server_1" {
  ami                    = "ami-06878d265978313ca"
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.az_a.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hola JorgeCarmine! Soy server 1" > index.html
                nohup busybox httpd -f -p ${var.server_port}
                EOF

  tags = {
    Name = "First server"
  }
}

resource "aws_instance" "carmine_server_2" {
  ami                    = "ami-06878d265978313ca"
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.az_b.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  user_data              = <<-EOF
                #!/bin/bash
                echo "Hola JorgeCarmine! Soy server 2" > index.html
                nohup busybox httpd -f -p ${var.server_port}
                EOF

  tags = {
    Name = "Second server"
  }
}

# Security group de las EC2s
resource "aws_security_group" "ec2_security_group" {
  name = "main-server"
  ingress {
    # cidr_blocks = [ "0.0.0.0/0" ]
    security_groups = [aws_security_group.carmine_alb_sg.id]
    description     = "Public access from ${var.server_port} port"
    from_port       = var.server_port
    to_port         = var.server_port
    protocol        = "TCP"
  }
}


resource "aws_lb" "carmine_alb" {
  load_balancer_type = "application"
  name               = "carmine-alb"
  security_groups    = [aws_security_group.carmine_alb_sg.id]
  subnets            = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
}

# Security group del load balancer
resource "aws_security_group" "carmine_alb_sg" {
  name = "carmine-alb-sg"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Public access"
    from_port   = var.load_balancer_port
    to_port     = var.load_balancer_port
    protocol    = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto ${var.server_port} de las EC2s"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "TCP"
  }
}

resource "aws_lb_target_group" "this" {
  name     = "carmine-alb-target-group"
  port     = var.load_balancer_port
  vpc_id   = data.aws_vpc.default.id
  protocol = "HTTP"

  health_check {
    enabled  = true
    matcher  = "200"
    path     = "/"
    port     = var.server_port
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "server_1_attachment" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.carmine_server_1.id
  port             = var.server_port
}

resource "aws_lb_target_group_attachment" "server_2_attachment" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.carmine_server_2.id
  port             = var.server_port
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.carmine_alb.arn
  port              = var.load_balancer_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}
