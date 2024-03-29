provider "aws" {
  region = "eu-west-2"
}

module "asg" {
  source = "../modules/cluster/asg-rolling-deploy"

  cluster_name  = var.cluster_name
  ami_image     = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  min_size                    = 1
  max_size                    = 1
  enable_autoscaling_schedule = false

  subnet_ids = data.aws_subnets.default.ids
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
