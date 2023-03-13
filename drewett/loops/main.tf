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