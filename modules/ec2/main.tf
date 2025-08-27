resource "aws_security_group" "ec2_sg" {
  name        = "${var.env}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # HTTP from ALB security group only
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # HTTPS from ALB security group only
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # SSH from your PC IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # SSH from EC2 Instance Connect (ap-south-1)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["13.233.177.0/29"] # EC2 Instance Connect IP range for ap-south-1
  }

  # HTTP from your IP for debugging
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # All outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env}-ec2-sg" }
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.env}-ec2-keypair"
  public_key = var.public_key

  tags = { Name = "${var.env}-ec2-keypair" }
}

resource "aws_instance" "web" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.ec2_key.key_name

  user_data = <<-EOF
#!/bin/bash
# Set up logging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting user data script at $(date)"

# Update system and install packages - Amazon Linux 2023 specific
echo "Updating system packages..."
dnf update -y
dnf install httpd wget unzip -y

# Start and enable httpd immediately
echo "Starting Apache HTTP server..."
systemctl start httpd
systemctl enable httpd

# Ensure httpd is running
sleep 2
systemctl status httpd

# Create immediate simple index.html (CRITICAL for ALB health check)
echo "Creating immediate index.html for health checks..."
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Moso Interior - Loading</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #f8f9fa; }
        .loading { color: #007bff; }
        .spinner { border: 4px solid #f3f3f3; border-top: 4px solid #007bff; border-radius: 50%; width: 40px; height: 40px; animation: spin 2s linear infinite; margin: 20px auto; }
        @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <h1 class="loading">� Moso Interior</h1>
    <div class="spinner"></div>
    <p>Server is healthy and running!</p>
    <p>Website is loading... Please wait.</p>
    <p>Amazon Linux 2023 - Apache HTTP Server</p>
    <p>Server started at: $(date)</p>
</body>
</html>
HTML

# Set proper permissions immediately
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart httpd to ensure it's serving the initial page
systemctl restart httpd
echo "Apache restarted, initial page should be available"

# Test local connectivity to ensure health checks will pass
sleep 3
curl -I http://localhost/
if [ $? -eq 0 ]; then
    echo "✅ Local web server test successful - health checks should pass"
else
    echo "❌ Local web server test failed"
    systemctl status httpd
    ss -tlnp | grep :80
fi

# Now download and setup the Moso Interior website (in background)
echo "Downloading Moso Interior website..."
cd /tmp

# Download the Moso Interior template
DOWNLOAD_SUCCESS=false
for attempt in {1..3}; do
    echo "Download attempt $attempt for Moso Interior..."
    wget -T 30 -t 1 "https://www.tooplate.com/zip-templates/2133_moso_interior.zip"
    if [ $? -eq 0 ] && [ -f "2133_moso_interior.zip" ]; then
        echo "✅ Moso Interior download successful on attempt $attempt"
        DOWNLOAD_SUCCESS=true
        break
    else
        echo "❌ Download attempt $attempt failed"
        sleep 5
    fi
done

if [ "$DOWNLOAD_SUCCESS" = true ]; then
    echo "Extracting and installing Moso Interior website..."
    unzip -o 2133_moso_interior.zip
    if [ -d "2133_moso_interior" ]; then
        # Backup the loading page first
        cp /var/www/html/index.html /tmp/loading_backup.html
        
        # Copy the new website files
        cp -r 2133_moso_interior/* /var/www/html/
        echo "✅ Moso Interior website files copied successfully"
        
        # Ensure index.html exists in the copied content
        if [ ! -f "/var/www/html/index.html" ]; then
            echo "⚠️ No index.html found in Moso Interior template, restoring loading page..."
            cp /tmp/loading_backup.html /var/www/html/index.html
        fi
    else
        echo "❌ Extraction failed, keeping loading page"
    fi
else
    echo "❌ All download attempts failed, using loading page as fallback"
fi

# Final permission and ownership setup
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Final restart to ensure everything is working
systemctl restart httpd

# Final health check
sleep 3
curl -s http://localhost/ > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Final health check successful - Moso Interior website is ready!"
else
    echo "❌ Final health check failed"
    systemctl status httpd
    ls -la /var/www/html/
fi

echo "User data script completed at $(date)"
echo "🚀 Server setup complete!"
EOF

  tags = { Name = "${var.env}-ec2-${count.index}" }
}