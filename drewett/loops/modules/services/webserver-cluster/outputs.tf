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

output "asg_name" {
  value       = aws_autoscaling_group.linux_asg.name
  description = "The name of the autoscaling group"
}

output "alb_security_group_id" {
  value       = aws_security_group.alb_sg.id
  description = "The ID of the security group attached to the load balancer"
}