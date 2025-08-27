variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}
