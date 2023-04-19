## Only viable if we deployed a single AWS EC2 instance
# output "public_ip" {
#   value       = aws_instance.linux.public_ip
#   description = "The public IP address of the web server"
# }

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "The DNS Name of the Load Balancer"
}

output "asg_name" {
  value       = module.asg.asg_name
  description = "The name of the autoscaling group"
}

output "alb_security_group_id" {
  value       = module.asg.instance_security_group_id
  description = "The ID of the security group attached to the EC2"
}