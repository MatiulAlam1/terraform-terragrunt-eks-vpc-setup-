# EKS Cluster Post-Deployment Setup Script for Windows
Write-Host "🚀 Setting up EKS cluster access..." -ForegroundColor Green

# Variables
$ClusterName = "dev-eks"
$Region = "ap-south-1"

# 1. Configure kubectl
Write-Host "📝 Configuring kubectl..." -ForegroundColor Yellow
aws eks update-kubeconfig --region $Region --name $ClusterName

# 2. Verify cluster connection
Write-Host "🔍 Verifying cluster connection..." -ForegroundColor Yellow
kubectl get nodes
kubectl get services -A

# 3. Wait for Load Balancer Controller to be ready
Write-Host "⏳ Waiting for AWS Load Balancer Controller..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n kube-system

# 4. Check sample application
Write-Host "📱 Checking sample application..." -ForegroundColor Yellow
kubectl get pods -l app=sample-app
kubectl get services sample-app-service
kubectl get ingress sample-app-ingress

# 5. Get Load Balancer URL
Write-Host "🌐 Getting Load Balancer URL..." -ForegroundColor Yellow
Write-Host "Waiting for ingress to get an address (this may take 2-3 minutes)..." -ForegroundColor Cyan

do {
    $Address = kubectl get ingress sample-app-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null
    if ($Address) {
        Write-Host "✅ Sample application is available at: http://$Address" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 10
    Write-Host "." -NoNewline -ForegroundColor Cyan
} while ($true)

Write-Host ""
Write-Host "🎉 Setup complete! Your EKS cluster is ready for browser access." -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Access your sample app at: http://$Address" -ForegroundColor White
Write-Host "2. Deploy your own applications using kubectl" -ForegroundColor White
Write-Host "3. Create additional ingresses for more services" -ForegroundColor White
Write-Host ""
Write-Host "📚 Useful commands:" -ForegroundColor Yellow
Write-Host "• kubectl get all                    # View all resources" -ForegroundColor White
Write-Host "• kubectl get ingress               # View ingresses and their URLs" -ForegroundColor White
Write-Host "• kubectl logs -l app=sample-app    # View application logs" -ForegroundColor White
Write-Host "• kubectl describe ingress sample-app-ingress  # Debug ingress issues" -ForegroundColor White

# Open browser automatically
if ($Address) {
    $choice = Read-Host "Would you like to open the application in your default browser? (y/n)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        Start-Process "http://$Address"
    }
}
