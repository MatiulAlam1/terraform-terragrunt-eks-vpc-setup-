terraform {
  backend "s3" {}
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"  # Use AWS provider 5.x to match module constraints
    }
  }
  
  required_version = ">= 1.0"
}

# VPC Module
module "vpc" {
  source = "./vpc"

  env        = var.env
  cidr_block = var.cidr_block
}

# ALB Module
module "alb" {
  source = "./alb"

  env        = var.env
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}

# EC2 Module
module "ec2" {
  source = "./ec2"

  env                   = var.env
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_ids            = module.vpc.public_subnet_ids
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  my_ip                 = var.my_ip
  public_key            = var.public_key
}

# Attach EC2 instances to ALB target group
resource "aws_lb_target_group_attachment" "ec2_attachment" {
  count            = length(module.ec2.instance_ids)
  target_group_arn = module.alb.target_group_arn
  target_id        = module.ec2.instance_ids[count.index]
  port             = 80

  depends_on = [
    module.alb,
    module.ec2
  ]
}

# EKS Module (for containerized workloads)
module "eks" {
  count  = var.enable_eks ? 1 : 0
  source = "./eks"

  cluster_name    = "${var.env}-eks"  # Shortened name to avoid length issues
  cluster_version = var.eks_cluster_version
  env             = var.env
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = var.cidr_block
  subnet_ids      = module.vpc.private_subnet_ids # Use private subnets for security
  my_ip           = var.my_ip                     # Pass IP for secure API access

  # Node group configuration
  node_instance_types     = var.eks_node_instance_types
  node_group_min_size     = var.eks_node_group_min_size
  node_group_max_size     = var.eks_node_group_max_size
  node_group_desired_size = var.eks_node_group_desired_size

  # Optional: Enable Fargate
  enable_fargate = false

  # Optional: SSH access to EKS nodes (reuse EC2 key pair name)
  key_name = "${var.env}-ec2-keypair"
}
