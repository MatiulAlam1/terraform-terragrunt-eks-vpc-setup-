# Terraform Terragrunt EKS VPC Setup

This repository provides infrastructure as code (IaC) templates to deploy an **Amazon EKS (Elastic Kubernetes Service)** cluster with a **VPC (Virtual Private Cloud)** using **Terraform** and **Terragrunt**.

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
