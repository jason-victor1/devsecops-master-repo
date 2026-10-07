output "bastion_instance_id" {
  description = "EC2 Instance ID of the SSM bastion"
  value       = aws_instance.bastion.id
}

output "bastion_security_group_id" {
  description = "Security group ID of the SSM bastion"
  value       = aws_security_group.bastion.id
}
