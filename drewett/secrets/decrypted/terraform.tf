data "aws_kms_secrets" "credentials" {
  secret {
    name    = "db"
    payload = file("db-creds.yml.encrypted")
  }
}

locals {
  db_creds = yamldecode(data.aws_kms_secrets.credentials.plaintext["db"])
}

resource "aws_db_instance" "mysql" {
  identifier_prefix   = "drewett-db"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  db_name             = "mysql"

  username = local.db_creds.username
  password = local.db_creds.password
}

# provider "aws" {
#     region = "eu-west-2"
# }

# data "aws_caller_identity" "self" {

# }

# data "aws_iam_policy_document" "cmk_admin_policy" {
#     statement {
#         effect = "Allow"
#         resources = ["*"]
#         actions = ["kms:*"]
#         principals {
#             type = "AWS"
#             identifiers = [data.aws_caller_identity.self.arn]
#         }
#     }
# }

# resource "aws_kms_key" "cmk" {
#     policy = data.aws_iam_policy_document.cmk_admin_policy.json
# }

# resource "aws_kms_alias" "cmk" {
#     name = "alias/kms-cmk-alias"
#     target_key_id = aws_kms_key.cmk.id
# }
