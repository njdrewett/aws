provider "aws" {
  region = "eu-west-2"
}

module "mysql" {
  source = "../../modules/data-stores/mysql"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

terraform {
  backend "s3" {
  }
}