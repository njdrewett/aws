provider "aws" {
  region = "eu-west-2"
}

module "webserver_cluster" {
  source = "git::https://github.com/njdrewett/aws.git//drewett/versioning/modules/services/webserver-cluster?ref=v0.0.1"

  # Override AMI and the server text
  ami_image   = "ami-0aaa5410833273cfe"
  server_text = "This is staging"

  # Override the clusternames and state keys referenced in the modules main and veriables section

  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "drewett-terraform-state"
  db_remote_state_key    = "global/s3/stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2

  enable_autoscaling_schedule = false
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}