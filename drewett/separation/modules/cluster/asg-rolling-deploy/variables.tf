
variable "server_port" {
  description = "The Port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to run (e.g. t2.micro)"
  type        = string

  validation {
    condition = contains(["t2.micro","t3.micro"], var.instance_type) 
    error_message = "only free tier instance types of t2.micro and t3.micro can be used"
  }
}

variable "min_size" {
  description = " The minimum number of EC2 instances in the ASG"
  type        = number

  validation {
    condition = var.min_size > 0 
    error_message = "Minimum number of EC2 instances must be greater than 0"
  }

  validation {
    condition = var.min_size <= 10
    error_message = "Maximum numbe rof EC2 instance must be less than 10 due to costs"
  }
}

variable "max_size" {
  description = " The maximum number of EC2 instances in the ASG"
  type        = number
}

variable "enable_autoscaling_schedule" {
  description = "If set to true, enable auto scaling schedule"
  type        = bool
}

variable "ami_image" {
  description = "The AMI to run in this cluster"
  type        = string
  default     = "ami-0aaa5410833273cfe"
}

## allow loopable for each dynamic tags
variable "custom_tags" {
  description = "Custom tags to set on the instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "The Subnet Ids to deploy to"
  type = list(string)
}

variable "target_group_arns" {
  description = "THE ARNs of the ELB target groups in which to register instances"
  type = list(string)
  default = []
}

variable "health_check_type" {
  description = "The type of health check to perform"
  type = string
  default = "EC2"
}

variable "user_data" {
  description = "The User Data script to run in each instance on boot"
  type = string
  default = null
}