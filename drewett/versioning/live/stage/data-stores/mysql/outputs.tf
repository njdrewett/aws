output "address" {
  value       = aws_db_instance.mysql.address
  description = "Connection endpoint to the database"
}

output "port" {
  value       = aws_db_instance.mysql.port
  description = "The exposed Prt of the database connection"
}

