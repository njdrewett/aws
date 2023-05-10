## Only viable if we deployed a single AWS EC2 instance
# output "public_ip" {
#   value       = aws_instance.linux.public_ip
#   description = "The public IP address of the web server"
# }

output "alb_dns_name" {
  value       = module.hello_world_app.alb_dns_name
  description = "The DNS Name of the Load Balancer"
}

output "asg_name" {
  value       = module.hello_world_app.asg_name
  description = "The name of the autoscaling group"
}
