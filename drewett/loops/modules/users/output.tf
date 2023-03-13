output "user_arn" {
  description = "The ARN of the user"
  value       = aws_iam_user.user.arn
}
