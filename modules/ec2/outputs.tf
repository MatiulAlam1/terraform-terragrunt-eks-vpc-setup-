output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "List of public IP addresses of the EC2 instances"
  value       = aws_instance.web[*].public_ip
}

output "instance_private_ips" {
  description = "List of private IP addresses of the EC2 instances"
  value       = aws_instance.web[*].private_ip
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "key_pair_name" {
  description = "Name of the EC2 key pair"
  value       = aws_key_pair.ec2_key.key_name
}