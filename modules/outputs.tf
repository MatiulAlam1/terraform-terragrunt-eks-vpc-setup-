output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_group_arn
}

output "ec2_instance_ids" {
  description = "IDs of the EC2 instances"
  value       = module.ec2.instance_ids
}

output "ec2_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = module.ec2.instance_public_ips
}

output "ec2_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = module.ec2.instance_private_ips
}

output "key_pair_name" {
  description = "Name of the EC2 key pair"
  value       = module.ec2.key_pair_name
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.alb.alb_security_group_id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.ec2.security_group_id
}

# EKS outputs (conditional)
output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_arn : null
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = var.enable_eks ? module.eks[0].cluster_endpoint : null
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_name : null
}

output "eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = var.enable_eks ? module.eks[0].cluster_oidc_issuer_url : null
}

output "eks_cluster_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = var.enable_eks ? module.eks[0].cluster_security_group_id : null
}

output "eks_node_security_group_id" {
  description = "ID of the node shared security group"
  value       = var.enable_eks ? module.eks[0].node_security_group_id : null
}

# Browser Access Information
output "browser_access_instructions" {
  description = "Instructions for accessing applications via browser"
  value = var.enable_eks ? {
    setup_command    = "Run: ./setup-eks-access.ps1 (Windows) or ./setup-eks-access.sh (Linux/Mac)"
    kubectl_config   = module.eks[0].kubectl_config_command
    sample_app_info  = module.eks[0].sample_app_url
    alb_url         = "Traditional EC2 ALB: http://${module.alb.alb_dns_name}"
    note            = "EKS applications will get their own load balancer URLs via ingress"
  } : {
    alb_url = "Traditional EC2 ALB: http://${module.alb.alb_dns_name}"
    note    = "EKS is disabled. Only EC2 ALB is available."
  }
}
