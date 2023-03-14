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