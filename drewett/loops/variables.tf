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


variable "user_names_set" {
  description = " Array List of user names to be used as a for_each set"
  type        = list(string)
  default     = ["NeilSet", "JamesSet", "FredSet"]
}

variable "user_names_set2" {
  description = " Array List of user names to be used as a for_each set"
  type        = list(string)
  default     = ["NeilSet2", "JamesSet2", "FredSet2"]
}

variable "starwars" {
  description = "map"
  type        = map(string)
  default = {
    han  = "solo"
    leia = "princess"
    luke = "skywalker"
  }
}

variable "newnames" {
  description = "Names to render using string directive"
  type        = list(string)
  default     = ["Mathew", "Mark", "Luke"]
}