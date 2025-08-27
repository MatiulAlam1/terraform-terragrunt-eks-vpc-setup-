# 🌐 Browser Access Guide for AWS Infrastructure

## Overview
Your infrastructure provides multiple ways to access applications via browser:

### 1. **Traditional EC2 + ALB Access**
- ✅ **Available immediately** after deployment
- 🔗 **URL**: Your ALB DNS name (provided in outputs)
- 📊 **Use case**: Traditional web applications on EC2

### 2. **EKS + Application Load Balancer Access**
- ⏳ **Available after** EKS deployment + setup
- 🔗 **URL**: Dynamic URLs created by AWS Load Balancer Controller
- 📊 **Use case**: Modern containerized applications

## 🚀 Quick Start (After Deployment)

### Step 1: Deploy Infrastructure
```bash
cd live/dev
terragrunt apply
```

### Step 2: Access Applications

#### Option A: EC2 Applications (Immediate)
```
http://[ALB-DNS-NAME]
```
*Replace [ALB-DNS-NAME] with the ALB DNS from terragrunt outputs*

#### Option B: EKS Applications (Requires Setup)
```powershell
# Windows
./setup-eks-access.ps1

# Linux/Mac  
./setup-eks-access.sh
```

## 🔧 EKS Browser Access Details

### What Gets Created Automatically:
1. **AWS Load Balancer Controller** - Manages ALB creation
2. **Sample Nginx Application** - Ready-to-use web app
3. **Kubernetes Ingress** - Routes traffic to the app
4. **Application Load Balancer** - AWS ALB for external access

### Expected URLs:
```
Traditional EC2: http://dev-alb-123456789.ap-south-1.elb.amazonaws.com
EKS Sample App:  http://k8s-default-sampleapp-abc123def.ap-south-1.elb.amazonaws.com
```

## 📋 Manual Setup (Alternative)

If you prefer manual setup:

### 1. Configure kubectl
```bash
aws eks update-kubeconfig --region ap-south-1 --name dev-eks
```

### 2. Verify cluster access
```bash
kubectl get nodes
kubectl get services -A
```

### 3. Check sample application
```bash
kubectl get pods -l app=sample-app
kubectl get ingress sample-app-ingress
```

### 4. Get load balancer URL
```bash
kubectl get ingress sample-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## 🎯 Deploy Your Own Applications

### Method 1: Using kubectl
```bash
# Deploy your app
kubectl create deployment my-app --image=nginx
kubectl expose deployment my-app --port=80 --type=LoadBalancer

# Get URL
kubectl get services my-app
```

### Method 2: Using Ingress (Recommended)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - http:
      paths:
      - path: /my-app
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

## 🔍 Troubleshooting

### Common Issues:

#### "Ingress has no address"
```bash
# Check load balancer controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check ingress events
kubectl describe ingress sample-app-ingress
```

#### "Service unavailable"
```bash
# Check pod status
kubectl get pods -l app=sample-app

# Check service endpoints
kubectl get endpoints sample-app-service
```

#### "Can't reach URL"
```bash
# Verify security groups allow HTTP traffic
aws ec2 describe-security-groups --group-ids [ALB-SECURITY-GROUP-ID]
```

## 📊 Architecture Flow

```
Internet → AWS ALB → EKS Pods (Private Subnets)
     ↑              ↑
  Public Subnet    Private Subnet
   (ALB here)      (Pods here)
```

## 🎉 Success Indicators

When everything works correctly, you should see:
- ✅ ALB DNS name in terraform outputs
- ✅ EKS pods running: `kubectl get pods`
- ✅ Ingress with ADDRESS: `kubectl get ingress`
- ✅ Web page loads in browser
- ✅ Load balancer health checks passing

## 💡 Tips

1. **DNS Propagation**: ALB URLs may take 2-3 minutes to become accessible
2. **Health Checks**: Ensure your app responds to health check paths
3. **Security Groups**: ALB security groups are automatically configured
4. **SSL/HTTPS**: Add SSL certificates via ingress annotations for HTTPS
5. **Custom Domains**: Point your domain to the ALB DNS name with CNAME

## 🔗 Useful Commands

```bash
# View all ingresses and their URLs
kubectl get ingress -A

# Monitor ingress creation
kubectl get ingress -w

# Check ALB in AWS Console
aws elbv2 describe-load-balancers --region ap-south-1

# View application logs
kubectl logs -l app=sample-app

# Scale application
kubectl scale deployment sample-app --replicas=3
```
