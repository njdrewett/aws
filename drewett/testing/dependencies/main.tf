provider "aws" {
  region = "eu-west-2"
}

module "hello_world_app" {
  source = "../modules/services/hello-world-app"

  server_text = "hello, neil"

  environment = "drewett"

  db_remote_state_bucket = "drewett-terraform-state"
  db_remote_state_key    = "global/s3/stage/data-stores/mysql/terraform.tfstate"

  mysql_config = var.mysql_config

  instance_type               = "t2.micro"
  min_size                    = 2
  max_size                    = 2
  enable_autoscaling_schedule = false
  ami_image                   = data.aws_ami.ubuntu.id
  cluster_name                = "cluster1"
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]

  }
}
