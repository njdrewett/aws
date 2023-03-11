## Only viable if we deployed a single AWS EC2 instance
# output "public_ip" {
#   value       = aws_instance.linux.public_ip
#   description = "The public IP address of the web server"
# }

output "alb_dns_name" {
  value       = aws_lb.linux_lb.dns_name
  description = "The DNS Name of the Load Balancer"
}

output "server_port" {
  value = var.server_port
}

