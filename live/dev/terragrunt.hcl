include {
  path = find_in_parent_folders()
}

locals {
  env        = "dev"
  cidr_block = "10.1.0.0/16"
  ami_id     = "ami-0d54604676873b4ec" 
  my_ip      = "103.197.206.34/32"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnJtvewJpLA+Xiz+mX8Vf54nnLUT8QwIuQMso3icx/c Bjit@10310-Matiul-Alam"
}

terraform {
  source = "../../modules//"
}

inputs = {
  env           = local.env
  cidr_block    = local.cidr_block
  ami_id        = local.ami_id
  instance_type = "t2.micro"
  my_ip         = local.my_ip
  public_key    = local.public_key
  
  # EKS configuration (set to true to enable EKS)
  enable_eks                    = true   # Enabled EKS deployment
  eks_cluster_version          = "1.28"
  eks_node_instance_types      = ["t3.small"]  # Changed from t2.micro to t3.small (minimum for EKS)
  eks_node_group_min_size      = 1
  eks_node_group_max_size      = 3
  eks_node_group_desired_size  = 1
}