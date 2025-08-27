# 🚀 AWS Moso Interior Multi-Tier Architecture Terraform Deployment

Welcome to the **Moso Interior Website** infrastructure deployment using Terraform!  
This environment is designed for high-availability, web hosting, and secure access — deployed in **AWS ap-south-1 (Mumbai)**.

---

## 📦 Overview

This project uses [Terraform](https://www.terraform.io/) to provision:

- A custom **VPC** with two public subnets
- An **Internet Gateway** for outbound internet access
- Two EC2 instances running Amazon Linux 2023 & Apache, configured via user-data for robust web hosting (with automatic deployment of "Moso Interior" template from Tooplate)
- **Security Groups** for controlled access (ALB & EC2)
- An importable **SSH key pair** for secure instance login

---

## 📂 Resource Summary

| Resource Type            | Name/ID                        | Purpose                                         |
|--------------------------|--------------------------------|-------------------------------------------------|
| VPC                      | `test-vpc` (vpc-022afc07b2b1fbd45)      | Segregated network for all resources             |
| Subnets                  | `test-public-subnet-1`, `test-public-subnet-2` | Publicly accessible app tiers                |
| Internet Gateway         | igw-0665b0bcef8e17200          | Enables internet connectivity                    |
| Security Group (ALB)     | `test-alb-sg` (sg-0bad0dc00099427b2)   | Allows HTTP/HTTPS globally                       |
| Security Group (EC2)     | `test-ec2-sg` (sg-01e0a297c6f969ebd)   | Restricts SSH/Web to trusted IPs/ALB             |
| EC2 Instances            | `test-ec2-0`, `test-ec2-1`              | Apache servers auto-deploying website            |
| Key Pair                 | `test-ec2-keypair`                      | Secure SSH authentication                        |

**Key Points:**
- All web traffic flows through ALB SG to EC2 SG for ports 80 (HTTP) and 443 (HTTPS).
- Direct SSH/Web access to EC2 is locked down to specific CIDR blocks only (e.g., `103.197.206.34/32`).

---

## 🖥️ Access Details

| Instance    | Public IP       | SSH Command Example                                                                                     | Web Access           |
|-------------|-----------------|--------------------------------------------------------------------------------------------------------|----------------------|
| test-ec2-0  | 35.154.40.221   | `ssh -i <your-private-key> ec2-user@35.154.40.221`                                                     | http://35.154.40.221 |
| test-ec2-1  | 13.233.53.181   | `ssh -i <your-private-key> ec2-user@13.233.53.181`                                                     | http://13.233.53.181 |

> ⚠️ **Note:**  
> - Replace `<your-private-key>` with the path to your private key matching the deployed `test-ec2-keypair`.
> - Only whitelisted source IPs can connect over SSH and direct HTTP.

---

## 🔒 Security Group Rules Summary

| SG Name      | Ingress Source(s)  | Allowed Ports        | Purpose                                         |
|--------------|--------------------|---------------------|-------------------------------------------------|
| alb_sg       | 0.0.0.0/0          | 80, 443             | Public web entry points                         |
| ec2_sg       | ALB SG, Admin IPs  | 80, 443, 22         | App/web & maintenance from safe sources         |

---

## ⚙️ User Data Bootstrapping (What happens at boot?)

Each EC2 runs a **user-data script** that:
1. Installs Apache (`httpd`), wget, unzip.
2. Creates an immediate loading page (for health checks & fast readiness).
3. Downloads and installs the "Moso Interior" template; falls back gracefully if download fails.
4. Ensures correct permissions and restarts Apache.
5. Logs progress to `/var/log/user-data.log`.

💡 **Purpose:**  
Ensures servers are *always* passing load balancer health checks and serving a valid HTML page even during initial setup.

---

## 🚧 Common Pitfalls to Avoid

- ❌ **Forgetting to use the right key pair** (`test-ec2-keypair`) when connecting over SSH.
- ❌ **Modifying security group rules** without considering access control risks.
- ❌ **Assuming instant website readiness:** Initial deployment may briefly serve a "loading" page before the full site is available.

---

## ▶️ How to Use

### 1. Prerequisites

- [Terraform v1.12.x or later](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Terragrunt v0.23+](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- AWS CLI configured (`aws configure`)
- Valid AWS credentials with permissions to deploy VPC/EC2/network resources

### 2. Set Up Remote Backend: S3 Bucket & DynamoDB Table
Before you use Terragrunt for deployment, it's best practice to centralize your Terraform state and enable state locking for safety. This is done by creating:

📦 An S3 bucket: Stores the shared Terraform state file.
💾 A DynamoDB table: Manages state locking to prevent concurrent modifications.

- aws s3api create-bucket --bucket my-terraform-states-ap-south-1 --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1
- aws dynamodb create-table --table-name terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST


### 3. Clone, Initialize, and Deploy

```bash
git clone <this-repo-url>
cd <project-directory>/live/test
terragrunt init
terragrunt plan      # Review upcoming changes
terragrunt apply     # Deploys resources (type 'yes' to confirm)

# To destroy resources created by Terraform
terragrunt destroy
