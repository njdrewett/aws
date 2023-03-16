provider "aws" {
  region = "eu-west-2"
}

## creates three users with an index from count (1,2,3)
resource "aws_iam_user" "users" {
  count = 3
  name  = "neil.${count.index}"
}

# Uses Variable loop for names
resource "aws_iam_user" "users_list" {
  count = length(var.names)
  name  = var.names[count.index]
}

module "users" {
  source = "./modules/users"

  count     = length(var.user_names)
  user_name = var.user_names[count.index]
}

resource "aws_iam_user" "userset" {
  for_each = toset(var.user_names_set)
  name     = each.value
}

module "users-set" {
  source = "./modules/users"

  for_each  = toset(var.user_names_set2)
  user_name = each.value
}

module "webserver_cluster" {
  source                 = "./modules/services/webserver-cluster"
  cluster_name           = "webservers-loop"
  db_remote_state_bucket = "drewett-terraform-state"
  db_remote_state_key    = "global/s3/stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 3
  custom_tags = {
    Owner     = "team-neil"
    ManagedBy = "neil"
  }

}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name   = "cloudwatch-read-only"
  policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name   = "cloudwatch-full-access"
  policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy_attachment" "neil_cloud_watch_full_access" {

  count      = var.give_neil_cloudwatch_full_access ? 1 : 0
  user       = aws_iam_user.users[0].name
  policy_arn = aws_iam_policy.cloudwatch_full_access.arn
}

resource "aws_iam_user_policy_attachment" "neil_cloud_watch_read_only" {
  count      = var.give_neil_cloudwatch_full_access ? 0 : 1
  user       = aws_iam_user.users[0].name
  policy_arn = aws_iam_policy.cloudwatch_read_only.arn
}