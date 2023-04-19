output "asg_name" {
  value       = aws_autoscaling_group.linux_asg.name
  description = "The name of the autoscaling group"
}

output "instance_security_group_id" {
  value       = aws_security_group.instance.id
  description = "The ID of the security group attached to the EC2"
}