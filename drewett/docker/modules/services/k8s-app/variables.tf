variable "name" {
  description = "The name to use for all resourcescreated by this module"
  type        = string
}

variable "image" {
  description = "The Docker Image to run"
  type        = string
}

variable "container_port" {
  description = "The port the docker image listens on"
  type        = number
}

variable "replicas" {
  description = "How many replicas to run"
  type        = number
}

variable "environment_variables" {
  description = "Environment Variables to set for the app"
  type        = map(string)
  default     = {}
}


