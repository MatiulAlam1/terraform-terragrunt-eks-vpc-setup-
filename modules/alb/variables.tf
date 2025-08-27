variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ALB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ALB will be deployed"
  type        = list(string)
}
