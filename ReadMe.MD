Terraform state definition

Store terraform state on an AWS S3 bucket

# setting up of S3 bucket would need to be done first (via  these terraforms) inorder to store in S3 bucket.
See comments in state.tf file.

terraform init -backend-config=backend.hcl
