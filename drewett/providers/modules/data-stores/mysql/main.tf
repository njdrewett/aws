terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_db_instance" "mysql" {
  identifier_prefix   = "drewett"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true


  #Enable backups
  backup_retention_period = var.backup_retention_period

  # If Specified, this DB will be a replica
  replicate_source_db = var.replicate_source_db

  # Only set these parameters if the replicate_source_db is not set
  engine   = var.replicate_source_db == null ? "mysql" : null
  db_name  = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? var.db_password : null
}

terraform {
  backend "s3" {
    #       bucket = "drewett-terraform-state"
    key = "global/s3/stage/data-stores/mysql/terraform.tfstate"
    #       region = "eu-west-2"

    #       dynamodb_table = "drewett-terraform-state-locks"
    #       encrypt = "true"
  }
}