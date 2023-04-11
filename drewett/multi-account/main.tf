# Providers to multiple AWS Accounts

provider "aws" {
    region = "eu-west-2"
    alias = "parent"
}

provider "aws" {
    region = "eu-west-2"
    alias = "child"

    ## Add the account_id and assumed role to AWS provider
    assume_role {
      role_arn = "arn:aws:iam::624804577413:role/OrganizationAccountAccessRole"
    }
}

# checks if working
data "aws_caller_identity" "parent" {
    provider = aws.parent
}

data "aws_caller_identity" "child" {
    provider = aws.child
}

module "multi_account_access" {
    source = "./modules/multi-account"

    providers = {
      aws.parent = aws.parent
      aws.child  = aws.child
     }
}