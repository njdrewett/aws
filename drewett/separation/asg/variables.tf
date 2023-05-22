

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type        = string
  default     = "drewett-cluster"
}

variable "instance_type" {
  description = "The instance type to use for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
