output "address" {
  value       = aws_db_instance.mysql.address
  description = "Connection endpoint to the database"
}

output "port" {
  value       = aws_db_instance.mysql.port
  description = "The exposed Prt of the database connection"
}

output "alb_dns_name" {
  value       = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer"
}