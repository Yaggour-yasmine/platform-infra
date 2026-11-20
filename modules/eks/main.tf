variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "Sous-réseaux privés pour les nœuds"
}

variable "cluster_version" {
  type        = string
  default     = "1.34"
  description = "Version Kubernetes. À vérifier avant chaque création (versions en support standard d'EKS)."
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.large"] # t3.medium est trop juste avec ArgoCD + Prometheus/Grafana
}

variable "node_desired_size" {
  type    = number
  default = 2
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      min_size       = 1
      desired_size   = var.node_desired_size
      max_size       = 4
    }
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
