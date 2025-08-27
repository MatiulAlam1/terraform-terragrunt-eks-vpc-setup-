#!/bin/bash
# EKS Deployment Script - Fixed Configuration
# This script deploys EKS with simplified configuration to avoid hanging issues

echo "=========================================="
echo "EKS Cluster Deployment - Fixed Configuration"
echo "=========================================="

# Navigate to dev environment
cd "$(dirname "$0")/live/dev" || exit 1

echo "🔍 Pre-deployment checks..."

# Check AWS credentials
echo "Checking AWS credentials..."
aws sts get-caller-identity > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ AWS credentials not configured properly"
    exit 1
fi
echo "✅ AWS credentials OK"

# Check AWS region
REGION=$(aws configure get region)
if [ -z "$REGION" ]; then
    echo "⚠️ No default region set, using ap-south-1"
    export AWS_DEFAULT_REGION=ap-south-1
else
    echo "✅ Using region: $REGION"
fi

# Check for existing cluster
echo "Checking for existing EKS cluster..."
EXISTING_CLUSTER=$(aws eks describe-cluster --name dev-eks --region ${AWS_DEFAULT_REGION:-$REGION} 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "⚠️ EKS cluster 'dev-eks' already exists"
    echo "Cluster status: $(echo $EXISTING_CLUSTER | jq -r '.cluster.status')"
    read -p "Do you want to continue with deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled"
        exit 1
    fi
fi

echo "🚀 Starting EKS deployment with fixed configuration..."

# Run terragrunt plan first
echo "Running terragrunt plan..."
terragrunt plan -target=module.vpc
if [ $? -ne 0 ]; then
    echo "❌ VPC planning failed"
    exit 1
fi

# Deploy VPC first
echo "Deploying VPC infrastructure..."
terragrunt apply -target=module.vpc -auto-approve
if [ $? -ne 0 ]; then
    echo "❌ VPC deployment failed"
    exit 1
fi
echo "✅ VPC deployed successfully"

# Wait a moment for VPC to stabilize
sleep 10

# Deploy EKS cluster
echo "Deploying EKS cluster (simplified configuration)..."
terragrunt apply -target=module.eks -auto-approve
if [ $? -ne 0 ]; then
    echo "❌ EKS deployment failed"
    echo "Checking for common issues..."
    
    # Check quotas
    echo "Checking service quotas..."
    aws service-quotas get-service-quota --service-code eks --quota-code L-1194D53C 2>/dev/null || echo "Could not check EKS quota"
    
    # Check instance limits
    echo "Checking EC2 instance limits..."
    aws ec2 describe-account-attributes --attribute-names supported-platforms 2>/dev/null || echo "Could not check EC2 attributes"
    
    exit 1
fi

echo "✅ EKS cluster deployed successfully"

# Configure kubectl
echo "Configuring kubectl..."
aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION:-$REGION} --name dev-eks
if [ $? -eq 0 ]; then
    echo "✅ kubectl configured successfully"
    
    # Test cluster access
    echo "Testing cluster access..."
    kubectl get nodes
    if [ $? -eq 0 ]; then
        echo "✅ Cluster access confirmed"
    else
        echo "⚠️ Cluster access test failed, but cluster is deployed"
    fi
else
    echo "⚠️ kubectl configuration failed, but cluster is deployed"
fi

echo "=========================================="
echo "🎉 EKS Deployment Completed!"
echo "=========================================="
echo "Cluster Name: dev-eks"
echo "Region: ${AWS_DEFAULT_REGION:-$REGION}"
echo "Instance Types: t3.small"
echo "Node Group: Simplified configuration"
echo ""
echo "Next steps:"
echo "1. Run: kubectl get nodes"
echo "2. Deploy applications using kubectl"
echo "3. Add IAM roles and policies as needed"
echo "=========================================="
