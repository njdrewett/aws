output "address" {
  value       = aws_db_instance.mysql.address
  description = "Connection endpoint to the database"
}

output "port" {
  value       = aws_db_instance.mysql.port
  description = "The exposed Port of the database connection"
}

output "arn" {
  value = aws_db_instance.mysql.arn
  description = "The ARN of the database"
}
