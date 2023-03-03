provider "aws" {
  region = "eu-west-2"
}

resource "aws_db_instance" "mysql" {
  identifier_prefix   = "drewett"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  db_name             = "drewett_db"

  username = var.db_username
  password = var.db_password
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