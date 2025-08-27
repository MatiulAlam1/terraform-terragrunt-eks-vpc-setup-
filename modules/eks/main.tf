# Data sources for availability zones and current region
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get authentication token for EKS cluster
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Note: KMS encryption removed for initial deployment to avoid hanging issues
# Can be added back after successful cluster creation

# Security group for SSH access to EKS worker nodes
resource "aws_security_group" "eks_node_ssh" {
  name_prefix = "${var.cluster_name}-node-ssh-"
  description = "Security group for SSH access to EKS worker nodes"
  vpc_id      = var.vpc_id

  # SSH access from bastion hosts (EC2 instances)
  ingress {
    description = "SSH from bastion hosts"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] # Allow SSH from your IP
  }

  # SSH access from within VPC (for bastion host access)
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Your VPC CIDR
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-node-ssh-sg"
    Environment = var.env
  }
}

# Official AWS EKS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"  # Use version compatible with AWS provider 5.x

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                               = var.vpc_id
  subnet_ids                           = var.subnet_ids
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # Allow from anywhere for initial setup

  # Simplified encryption config to avoid KMS dependency issues
  cluster_encryption_config = {}

  # Minimal cluster logging to reduce complexity
  cluster_enabled_log_types              = ["api", "audit"]
  cloudwatch_log_group_retention_in_days = 7

  # Simplified cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s) - Simplified
  eks_managed_node_group_defaults = {
    instance_types = var.node_instance_types
    ami_type       = "AL2_x86_64"
    disk_size      = 20
  }

  eks_managed_node_groups = {
    main = {
      name = "${var.cluster_name}-ng"  # Shortened node group name

      instance_types = var.node_instance_types

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      capacity_type = "ON_DEMAND"

      # Simplified update config
      update_config = {
        max_unavailable_percentage = 25
      }

      labels = {
        Environment = var.env
        NodeGroup   = "main"
      }

      tags = {
        ExtraTag = "EKS managed node group"
      }
    }
  }

  # Remove Fargate to simplify initial deployment
  fargate_profiles = {}

  # Simplified aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = []  # Simplify initially
  aws_auth_users = []
  aws_auth_accounts = []

  tags = {
    Environment = var.env
    Terraform   = "true"
    Application = "eks-cluster"
  }
}

# Simplified IAM role for EKS cluster access (remove complex dependencies)
# Note: Complex IAM roles moved to separate deployment for better reliability
