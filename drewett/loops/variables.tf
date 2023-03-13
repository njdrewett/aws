#List of names
variable "names" {
  description = " Array List of names"
  type        = list(string)
  default     = ["Neil", "James", "Fred"]
}

variable "user_names" {
  description = " Array List of user names"
  type        = list(string)
  default     = ["Neil2", "James2", "Fred2"]
}