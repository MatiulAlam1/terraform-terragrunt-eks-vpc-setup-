# EKS Access Configuration

## After Deployment, Configure kubectl Access

### 1. Update kubeconfig
```bash
aws eks update-kubeconfig --region ap-south-1 --name dev-eks
```

### 2. Verify Connection
```bash
kubectl get nodes
kubectl get services
```

### 3. Deploy Sample Application
```bash
# Deploy nginx
kubectl create deployment nginx --image=nginx

# Expose as LoadBalancer service
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check service status
kubectl get services -w
```

### 4. Access Application
Once the EXTERNAL-IP appears (takes 2-3 minutes), access via browser:
```
http://[EXTERNAL-IP]
```

## Alternative: Ingress Controller

### Install AWS Load Balancer Controller
```bash
# Create service account
kubectl create serviceaccount aws-load-balancer-controller -n kube-system

# Annotate with IAM role (already configured in Terraform)
kubectl annotate serviceaccount aws-load-balancer-controller -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::ACCOUNT-ID:role/dev-eks-alb

# Install controller via Helm
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=dev-eks \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### Create Ingress Resource
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```

## Current Status
- ✅ EKS cluster with AWS Load Balancer Controller IAM role configured
- ✅ Private subnets for security
- ✅ Public subnets available for load balancers
- ⚠️ No applications deployed yet
- ⚠️ No load balancers created yet

## Next Steps
1. Deploy EKS cluster: `terragrunt apply`
2. Configure kubectl access
3. Deploy your application
4. Create LoadBalancer service or Ingress
5. Access via browser using the generated AWS load balancer URL
