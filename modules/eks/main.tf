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

# KMS key for EKS cluster encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.cluster_name}-eks-encryption-key"
    Environment = var.env
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks-encryption-key"
  target_key_id = aws_kms_key.eks.key_id
}

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
  cluster_endpoint_public_access_cidrs = [var.my_ip]  # Restrict to your IP for security

  # Encryption config
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  # Cluster logging
  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = 7

  # Cluster addons
  cluster_addons = var.cluster_addons

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = var.node_instance_types
  }

  eks_managed_node_groups = {
    main = {
      name = "${var.cluster_name}-ng"  # Shortened node group name

      instance_types = var.node_instance_types

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      capacity_type = "ON_DEMAND"

      # Remove remote access to avoid launch template conflicts
      # Use AWS Systems Manager (SSM) for secure access instead

      update_config = {
        max_unavailable_percentage = 33
      }

      labels = {
        Environment = var.env
        NodeGroup   = "main"
      }

      taints = var.node_group_taints

      tags = {
        ExtraTag = "EKS managed node group"
      }
    }
  }

  # Fargate Profile(s)
  fargate_profiles = var.enable_fargate ? {
    default = {
      name = "${var.cluster_name}-fargate-profile"
      selectors = [
        {
          namespace = "fargate"
        },
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        }
      ]

      tags = {
        Owner = "fargate"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  } : {}

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = "cluster-admin"
      groups   = ["system:masters"]
    },
  ]

  aws_auth_users    = var.map_users
  aws_auth_accounts = var.map_accounts

  tags = {
    Environment = var.env
    Terraform   = "true"
    Application = "eks-cluster"
  }
}

# Additional IAM role for EKS admins
module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"  # Compatible version with EKS v19

  role_name = "${var.cluster_name}-admin"  # Shortened role name

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node", "kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Environment = var.env
  }
}

# AWS Load Balancer Controller IAM role
module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "${var.cluster_name}-alb"  # Shortened role name

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Environment = var.env
  }
}

# EBS CSI Driver IAM role
module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "${var.cluster_name}-ebs"  # Shortened role name

  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Environment = var.env
  }
}

# VPC CNI IAM role
module "vpc_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "${var.cluster_name}-vpc-cni"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = {
    Environment = var.env
  }
}
