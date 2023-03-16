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

output "all-user-names-set" {
  description = "all usernames from the set definition"
  value       = aws_iam_user.userset
}

output "all-user-names-set-arn" {
  description = "all usernames from the set definition"
  value       = values(aws_iam_user.userset)[*].arn
}

output "all-user-names-set-arn-module" {
  description = "all usernames from the set definition module"
  value       = values(module.users-set)[*].user_arn
}

# for expressions
output "uppernames" {
  value = [for name in var.names : upper(name)]
}

# for expression with condition
output "shortuppernames" {
  value = [for name in var.names : upper(name) if length(name) < 5]
}

output "starwars-characters" {
  value = [for name, role in var.starwars : "${name} is the ${role}"]
}

# expressions output 
output "starwars-characters-upper" {
  value = { for name, role in var.starwars : upper(name) => upper(role) }
}

output "names-for-directive" {
  value = "%{for name in var.newnames}${name}, %{endfor} "
}

output "names-for-directive-with-index" {
  value = "%{for i, name in var.newnames}(${i})${name}, %{endfor} "
}

output "names-for-directive-with-index_if" {
  value = <<EOF
%{for i, name in var.names}
${name}%{if i < length(var.names) - 1}, %{endif}
%{endfor}
EOF
}

output "names-for-directive-with-index-if-strip-markers" {
  value = <<EOF
%{~for i, name in var.names~}
${name}%{if i < length(var.names) - 1}, %{endif}
%{~endfor~}
EOF
}

output "names-for-directive-with-index-if-strip-markers-else" {
  value = <<EOF
%{~for i, name in var.names~}
${name}%{if i < length(var.names) - 1}, %{else}.%{endif}
%{~endfor~}
EOF
}

output "neil-cloudwatch-policy-arn" {
  value = one(concat(
    aws_iam_user_policy_attachment.neil_cloud_watch_full_access[*].policy_arn,
    aws_iam_user_policy_attachment.neil_cloud_watch_read_only[*].policy_arn
  ))
}