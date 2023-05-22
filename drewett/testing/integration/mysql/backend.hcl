# backend.hcl

bucket = "drewett-terraform-state"
key = "integration/data-stores/mysql/terraform.tfstate"
region = "eu-west-2"
dynamodb_table="drewett-terraform-state-locks"
encrypt = true
