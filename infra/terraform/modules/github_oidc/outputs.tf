output "role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "Role ARN for GitHub Actions configuration."
}
