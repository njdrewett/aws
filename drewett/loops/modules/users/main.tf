# as a module, being referenced using loop
resource "aws_iam_user" "user" {
  name = var.user_name
}

