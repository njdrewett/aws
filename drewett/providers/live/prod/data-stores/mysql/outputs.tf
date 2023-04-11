output "primary_address" {
    value = module.mysql_primary.address
    description = "Address of the Primary RDS"
}

output "primary_port" {
    value = module.mysql_primary.port
    description = "Port of the Primary RDS"
}

output "primary_arn" {
    value = module.mysql_primary.arn
    description = "The ARN of the primary database"
}

output "replica_address" {
    value = module.mysql_replica.address
    description = "Address of the Replica RDS"
}

output "replica_port" {
    value = module.mysql_replica.port
    description = "Port of the Replica RDS"
}

output "replica_arn" {
    value = module.mysql_replica.arn
    description = "The ARN of the Replica database"
}




