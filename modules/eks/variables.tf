variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster (ENIs) will be provisioned along with the nodes/node groups"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Set of instance types associated with the EKS Node Group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_min_size" {
  description = "Minimum number of instances/nodes"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of instances/nodes"
  type        = number
  default     = 10
}

variable "node_group_desired_size" {
  description = "Desired number of instances/nodes"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "EC2 Key Pair name that provides access for remote communication with the worker nodes in the EKS Node Group"
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

variable "enable_fargate" {
  description = "Enable Fargate profiles"
  type        = bool
  default     = false
}

variable "node_group_taints" {
  description = "The Kubernetes taints to be applied to the nodes in the node group"
  type        = any
  default     = {}
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true  # Enable private access for security
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this in production
}

variable "my_ip" {
  description = "Your IP address for secure EKS API access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster service account as a cluster admin"
  type        = bool
  default     = true
}

variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable"
  type        = any
  default = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
}
