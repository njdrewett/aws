
# Using alias to define the providers for different regions
provider "aws" {
  region = "eu-west-2"
  alias  = "region_1"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "region_2"
}



module "mysql_primary" {
  source  = "../../../../modules/data-stores/mysql"
  db_name = "prod_db"

  providers = {
    aws = aws.region_1
  }

  db_username = var.db_username
  db_password = var.db_password

  # must be enabled to support replication
  backup_retention_period = 1
}

module "mysql_replica" {
  source = "../../../../modules/data-stores/mysql"

  providers = {
    aws = aws.region_2
  }

  # make this a replica of the primary
  replicate_source_db = module.mysql_primary.arn
}

