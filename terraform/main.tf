
provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  nat_gateway_count    = 1
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = var.project_name
  kubernetes_version = var.kubernetes_version
  private_subnet_ids = module.network.private_subnet_ids
}
