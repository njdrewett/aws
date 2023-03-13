output "first-name" {
  description = "first name in the list of names"
  value       = aws_iam_user.users_list[0].arn
}

output "all-names" {
  description = "All name in the list of names"
  value       = aws_iam_user.users_list[*].arn
}

output "all-user-names" {
  description = "All user names"
  value       = module.users[*].user_arn
}