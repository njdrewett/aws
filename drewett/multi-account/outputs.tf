## for local outputs
output "parent_account_id" {
  value       = data.aws_caller_identity.parent
  description = " The Account id of the parent/root account"
}

output "child_account_id" {
  value       = data.aws_caller_identity.child
  description = " The Account id of the child account"
}
