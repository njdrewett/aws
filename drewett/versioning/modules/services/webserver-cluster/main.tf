
locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}


resource "aws_launch_configuration" "linux_launch_config" {
  image_id        = var.ami_image
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]

  user_data = templatefile("${path.module}\\user-data.sh", {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  })
  #Required when using asg due to dependency
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "linux_asg" {
  ## Explicitly depend on the launch configuration's name so that each time it
  # is replace, this ASG is also replaced
  name                 = "{var.cluster_name}-${aws_launch_configuration.linux_launch_config.name}"
  launch_configuration = aws_launch_configuration.linux_launch_config.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg_tg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  # Wait for at least this many instances to pass health checks before 
  # considering the ASG deployment complete
  min_elb_capacity = var.min_size

  # When replacing this ASG, create the replacement first, and only delete the original after
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = {
      for key, value in var.custom_tags :
      key => upper(value)
      if key != "Name"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_lb_listener_rule" "asg_lr" {
  listener_arn = aws_lb_listener.http.arn
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

# used to lookup subnets and ips
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "linux_lb" {
  name               = "${var.cluster_name}-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.linux_lb.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default return a simple error 404
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb_sg" {
  name = "${var.cluster_name}-alb-sg"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id

  # Allow inbound http requests
  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_http_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb_sg.id

  # Allow outbound http requests
  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_lb_target_group" "asg_tg" {
  name     = "${var.cluster_name}-asg-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

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

terraform {
  backend "s3" {
    #       bucket = "drewett-terraform-state"
    key = "global/s3/stage/services/webserver-cluster/terraform.tfstate"
    #       region = "eu-west-2"

    #       dynamodb_table = "drewett-terraform-state-locks"
    #       encrypt = "true"
  }
}


data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "eu-west-2"
  }
}

## needs reference to the output vairable from the module
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling_schedule ? 1 : 0

  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.linux_asg.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling_schedule ? 1 : 0

  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.linux_asg.name
}
