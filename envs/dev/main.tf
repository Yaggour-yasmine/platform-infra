terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # À remplacer par les valeurs affichées par `terraform apply` dans bootstrap/
  backend "s3" {
    bucket         = "REMPLACER-par-le-bucket-du-bootstrap"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "REMPLACER-par-la-table-de-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-3"

  default_tags {
    tags = {
      projet      = "plateforme-devops"
      environment = "dev"
      geree-par   = "terraform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name = "plateforme-dev"
  azs  = ["eu-west-3a", "eu-west-3b"]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = "plateforme-dev"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
}

resource "aws_ecr_repository" "sample_api" {
  name                 = "sample-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.sample_api.repository_url
}
