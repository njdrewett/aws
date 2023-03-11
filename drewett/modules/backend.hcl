# backend.hcl

bucket = "drewett-terraform-state"
region = "eu-west-2"
dynamodb_table="drewett-terraform-state-locks"
encrypt = true
