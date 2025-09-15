# Terraform Terragrunt EKS VPC Setup

Overview

This project provides a reusable and configurable setup to provision a Virtual Private Cloud (VPC) on AWS, specifically designed to meet the requirements for hosting an Amazon EKS (Elastic Kubernetes Service) cluster. It uses Terraform for infrastructure as code and Terragrunt to keep the configuration DRY (Don't Repeat Yourself) and manage remote state.

The resulting VPC includes:





Public and private subnets across multiple Availability Zones.



An Internet Gateway (IGW) for public internet access.



NAT Gateways in public subnets to allow private subnets to access the internet.



Appropriate route tables for public and private subnets.



Necessary tags on all resources, especially those required by EKS for auto-discovery (e.g., kubernetes.io/cluster/<cluster-name>).
---

## 📂 Project Structure

```
terraform-terragrunt-eks-vpc-setup/
│── live/                  # Terragrunt live configuration per environment
│   ├── dev/
│   ├── staging/
│   └── prod/
│── modules/               # Reusable Terraform modules
│   ├── vpc/
│   ├── eks/
│   └── node_group/
│── terragrunt.hcl          # Root Terragrunt configuration
│── README.md               # Project documentation
```

---

## 🚀 Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3
- [Terragrunt](https://terragrunt.gruntwork.io/) >= 0.42
- AWS CLI configured with proper credentials
- kubectl for managing EKS clusters

---

## ⚙️ Usage

### 1. Clone the repository

```bash
git clone https://github.com/your-org/terraform-terragrunt-eks-vpc-setup.git
cd terraform-terragrunt-eks-vpc-setup/live/dev
```

### 2. Initialize Terragrunt

```bash
terragrunt init
```

### 3. Plan the deployment

```bash
terragrunt plan
```

### 4. Apply the configuration

```bash
terragrunt apply
```

---

## 🏗 Modules

- **VPC**: Creates AWS VPC, subnets, NAT gateways, and routing tables.
- **EKS**: Provisions Amazon EKS control plane.
- **Node Group**: Manages worker nodes for EKS using managed node groups.

---

## 🔒 Security Best Practices

- Store state files in **S3 with DynamoDB for locking**.
- Use **IAM roles** instead of long-term credentials.
- Enable **encryption** for secrets in EKS (KMS).

---

## 📖 References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
