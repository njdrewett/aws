
# Define the data credentials.
provider "aws" {
  region = "eu-west-2"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "db-credentials"
}

locals {
  db_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.db_credentials.secret_string
  )
}

resource "aws_db_instance" "database" {
  identifier_prefix   = "njd-db"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true

  db_name = "db"

  #Pass the secrets to the resource
  username = local.db_credentials.username
  password = local.db_credentials.password
}