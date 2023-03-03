provider "aws" {
    region = "eu-west-2"  
}

# S3 Bucket for storing state
resource "aws_s3_bucket" "terraform_state" {
    bucket = "drewett-terraform-state"
    
    # Prevents accidental deletion of the S3 bucket
    lifecycle  {
        prevent_destroy = true
    }
}

# Enable Verioning so you can see the full revision history of state files
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

#Enables Server Side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

# Blocks public access to the S3 Bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# DynamoDB for actual state storage locks
resource "aws_dynamodb_table" "terraform_locks" {
    name = "drewett-terraform-state-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}


# if above is not applied first the below will fail till it is applied. This "chicken and egg" situation should really have a separation 
# of "init" code and "main apply" code
# We can use externalised config if we run "terraform init -backend-config=backend.hcl"
terraform {
    backend "s3" {
 #       bucket = "drewett-terraform-state"
        key = "global/s3/terraform.tfstate"
 #       region = "eu-west-2"

 #       dynamodb_table = "drewett-terraform-state-locks"
 #       encrypt = "true"
    }
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "The ARN of the S3 bucket"    
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
    description = "The name of the dynamoDB locks table"    
}
