variable "mysql_config" {
  description = "The config for the MYSQL DB"

  type = object({
    address = string
    port    = number
  })

  default = ({
    address = "mock-mysql-address"
    port    = 12345
  })

}

variable "environment" {
  description = "The name of the environment"
  type        = string
  default     = "drewett"
}

