variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs where EC2 instances will be launched"
  type        = list(string)
}

variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB to allow HTTP/HTTPS traffic from"
  type        = string
}

variable "my_ip" {
  description = "Your IP address in CIDR format (e.g., '203.0.113.1/32') for SSH access"
  type        = string
}

variable "public_key" {
  description = "The public key content for the EC2 key pair (contents of your .pub file)"
  type        = string
}
