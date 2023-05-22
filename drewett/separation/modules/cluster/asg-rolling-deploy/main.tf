
terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


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

  user_data = var.user_data
  #Required when using asg due to dependency
  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = data.aws_ec2_instance_type.instance.free_tier_eligible
      error_message = "${var.instance_type} is not part of the Free teir "
    }
  }

}

data "aws_ec2_instance_type" "instance" {
  instance_type = var.instance_type
}


resource "aws_autoscaling_group" "linux_asg" {
  ## Explicitly depend on the launch configuration's name so that each time it
  # is replace, this ASG is also replaced
  name                 = var.cluster_name
  launch_configuration = aws_launch_configuration.linux_launch_config.name
  vpc_zone_identifier  = var.subnet_ids

  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  # Wait for at least this many instances to pass health checks before 
  # considering the ASG deployment complete
  min_elb_capacity = var.min_size

  # When replacing this ASG, create the replacement first, and only delete the original after
  lifecycle {
    create_before_destroy = true

    postcondition {
      condition     = length(self.availability_zones) > 1
      error_message = "You must use more than one availability zone for high availability"
    }
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


# Security Group to allow access to the port 8080 of the above linux instance
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-sg-instance"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
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
