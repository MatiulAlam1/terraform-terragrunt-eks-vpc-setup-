# AWS 3-Tier Architecture with EKS

This Terragrunt project deploys a complete AWS infrastructure including:

## Architecture Overview

### 1. Network Layer (VPC)
- **VPC**: Custom VPC with public and private subnets
- **Public Subnets**: For ALB and NAT gateways (2 AZs)
- **Private Subnets**: For EKS worker nodes and secure workloads (2 AZs)
- **NAT Gateways**: Internet access for private subnets
- **Route Tables**: Properly configured for public/private subnet routing
- **Security**: Network ACLs for additional subnet-level security

### 2. Compute Layer

#### Traditional EC2 (Web Tier)
- **EC2 Instances**: t2.micro instances in public subnets
- **Auto Scaling**: Manual scaling via instance count
- **Security Groups**: SSH access restricted to your IP
- **SSH Key**: ED25519 key pair for secure access

#### Container Orchestration (EKS)
- **EKS Cluster**: Kubernetes 1.28 in private subnets for security
- **Worker Nodes**: t2.small managed node groups (1-3 nodes)
- **Security**: Private subnets with separate security groups
- **IAM**: IRSA (IAM Roles for Service Accounts) enabled
- **Logging**: CloudWatch integration
- **Networking**: VPC CNI with proper subnet tagging

### 3. Load Balancer Layer
- **Application Load Balancer**: Internet-facing ALB in public subnets
- **Target Groups**: Health checks for EC2 instances
- **Security Groups**: HTTP/HTTPS traffic allowed
- **Multi-AZ**: High availability across availability zones

## Security Features

### Network Security
- **Private Subnets**: EKS nodes isolated from direct internet access
- **NAT Gateways**: Secure outbound internet access for private subnets
- **Security Groups**: Principle of least privilege
- **Network ACLs**: Additional subnet-level security controls

### EKS Security
- **Cluster Endpoint**: Private API server access
- **Node Groups**: Launched in private subnets only
- **IAM Integration**: IRSA for pod-level IAM permissions
- **Encryption**: EKS secrets encrypted with KMS
- **Separate Security Groups**: EKS has its own security group rules

### Access Control
- **SSH Access**: Restricted to your IP address only
- **VPC Flow Logs**: Network traffic monitoring capability
- **CloudWatch**: Centralized logging for EKS

## Environment Structure

```
live/
├── dev/           # Development environment
├── test/          # Test environment  
└── prod/          # Production environment

modules/
├── vpc/           # VPC with public/private subnets
├── alb/           # Application Load Balancer
├── ec2/           # EC2 instances
└── eks/           # EKS cluster (using official AWS module)
```

## Key Features

### Hybrid Deployment Model
- **Traditional**: EC2 instances for legacy applications
- **Modern**: EKS for containerized microservices
- **Conditional**: EKS can be enabled/disabled per environment

### Production-Ready Configuration
- **Multi-AZ**: High availability across zones
- **Private Networking**: Secure EKS deployment
- **Proper Tagging**: Resource organization and cost tracking
- **Infrastructure as Code**: Fully automated deployment

## Deployment Commands

### Deploy Complete Infrastructure (with EKS)
```bash
cd live/dev
terragrunt apply
```

### Deploy Without EKS (EC2 only)
Set `enable_eks = false` in terragrunt.hcl, then:
```bash
cd live/dev
terragrunt apply
```

### Destroy Infrastructure
```bash
cd live/dev
terragrunt destroy
```

## Current Configuration (Dev Environment)

- **VPC CIDR**: 10.1.0.0/16
- **Public Subnets**: 10.1.1.0/24, 10.1.2.0/24
- **Private Subnets**: 10.1.3.0/24, 10.1.4.0/24
- **EKS Enabled**: Yes
- **EKS Instance Type**: t2.small
- **EKS Node Count**: 1-3 nodes (desired: 1)
- **EC2 Instance Type**: t2.micro

## Security Considerations Implemented

1. **Network Isolation**: EKS nodes in private subnets
2. **Least Privilege**: Separate security groups for different services
3. **Encryption**: KMS encryption for EKS secrets
4. **Access Control**: SSH restricted to authorized IP
5. **Monitoring**: CloudWatch logging enabled
6. **High Availability**: Multi-AZ deployment

This architecture provides a robust foundation for both traditional and modern cloud-native applications with strong security practices.
