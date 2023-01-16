variable "server_port" {
  description = "Default port for EC2 instances"
  type        = number
  default     = 8080
}

variable "load_balancer_port" {
  description = "Default port form application load balancer"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "Size of EC2 instances"
  type        = string
  default     = "t2.micro"
}
