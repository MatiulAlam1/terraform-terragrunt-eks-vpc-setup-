#!/bin/bash

# EKS Cluster Post-Deployment Setup Script
echo "🚀 Setting up EKS cluster access..."

# Variables
CLUSTER_NAME="dev-eks"
REGION="ap-south-1"

# 1. Configure kubectl
echo "📝 Configuring kubectl..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# 2. Verify cluster connection
echo "🔍 Verifying cluster connection..."
kubectl get nodes
kubectl get services -A

# 3. Wait for Load Balancer Controller to be ready
echo "⏳ Waiting for AWS Load Balancer Controller..."
kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system

# 4. Check sample application
echo "📱 Checking sample application..."
kubectl get pods -l app=sample-app
kubectl get services sample-app-service
kubectl get ingress sample-app-ingress

# 5. Get Load Balancer URL
echo "🌐 Getting Load Balancer URL..."
echo "Waiting for ingress to get an address (this may take 2-3 minutes)..."
kubectl get ingress sample-app-ingress -w &
WATCH_PID=$!

# Wait for ingress to get an address
while true; do
    ADDRESS=$(kubectl get ingress sample-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [[ -n "$ADDRESS" ]]; then
        kill $WATCH_PID 2>/dev/null
        echo "✅ Sample application is available at: http://$ADDRESS"
        break
    fi
    sleep 10
done

echo "🎉 Setup complete! Your EKS cluster is ready for browser access."
echo ""
echo "📋 Next steps:"
echo "1. Access your sample app at: http://$ADDRESS"
echo "2. Deploy your own applications using kubectl"
echo "3. Create additional ingresses for more services"
echo ""
echo "📚 Useful commands:"
echo "• kubectl get all                    # View all resources"
echo "• kubectl get ingress               # View ingresses and their URLs"
echo "• kubectl logs -l app=sample-app    # View application logs"
echo "• kubectl describe ingress sample-app-ingress  # Debug ingress issues"
