provider "aws" {
  region = "eu-west-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  # Override the clusternames and state keys referenced in the modules main and veriables section

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "drewett-terraform-state"
  db_remote_state_key = "global/s3/stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 2
}
