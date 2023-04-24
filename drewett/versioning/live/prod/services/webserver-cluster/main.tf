provider "aws" {
  region = "eu-west-2"
}

module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"

  # Override the clusternames and state keys referenced in the modules main and veriables section

  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "drewett-terraform-state"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"


  enable_autoscaling_schedule = true
}

