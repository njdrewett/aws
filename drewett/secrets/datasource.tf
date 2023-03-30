## Create a resource whihc has username and password but NOT defined in the code.
## Takes the username and password environemnt varibale/encrypted file/secret store

## for environment variables , 
## export TF_VAR_db_username=<username> or windows  Set-Item -Path env:TF_VAR_db_username -Value "myusername"
## export TF_VAR_db_password=<password> or windows  Set-Item -Path env:TF_VAR_db_password -Value "mypassword"

resource "aws_db_instance"  "mysql" {
    identifier_prefix = "drewett-db"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    skip_final_snapshot = true 
    db_name = var.db_name
  
    username = var.db_username
    password = var.db_password
}

variable "db_name" {
    description = "name of the database"
    type = string
    default = "mysql"    
}

variable "db_username" {
    description = "The username of the database"
    type = string
    sensitive = true
}

variable "db_password" {
    description = "The password of the database"
    type = string
    sensitive = true
}
