terraform {
  # Require any 1.x version of Terraform
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]

  mysql_config = (
    var.mysql_config == null ? data.terraform_remote_state.db[0].outputs : var.mysql_config
  )

  vpc_id = (
    var.vpc_id == null ? data.aws_vpc.default[0].id : var.vpc_id
  )

  subnet_ids = (
    var.subnet_ids == null ? data.aws_subnets.default[0].ids : var.subnet_ids
  )

}

resource "aws_lb_target_group" "asg_tg" {
  name     = "hello-world-${var.environment}"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg_lr" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_tg.arn
  }
}

# Security Group to allow access to the port 8080 of the above linux instance
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-sg-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  #Required if trying to recreate SG otherwise can hang due to instance dependency
  lifecycle {
    create_before_destroy = true
  }
}

module "asg" {
  source = "../../cluster/asg-rolling-deploy"

  cluster_name  = "hello-world-${var.environment}"
  ami_image     = var.ami_image
  instance_type = var.instance_type

  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    server_text = var.server_text
  })

  min_size                    = var.min_size
  max_size                    = var.max_size
  enable_autoscaling_schedule = var.enable_autoscaling_schedule

  subnet_ids        = local.subnet_ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

module "alb" {
  source = "../../networking/alb"

  alb_name   = "hello-world-${var.environment}"
  subnet_ids = local.subnet_ids
}

resource "aws_lb_target_group" "asg" {
  name     = "hello-world-${var.environment}"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
