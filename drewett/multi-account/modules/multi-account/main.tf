# We should add aws providers into moudles as they can cause duplication problems, 
# performance issues and configuration problems based on the account configuration data 

# This can be made partially modular by enforcing the providers block as a prerequisit

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
        configuration_aliases = [aws.parent, aws.child]
      }
    }
}

# checks if working
data "aws_caller_identity" "parent" {
    provider = aws.parent
}

data "aws_caller_identity" "child" {
    provider = aws.child
}