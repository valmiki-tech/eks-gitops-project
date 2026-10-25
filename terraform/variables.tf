variable "aws_region" {
  description = "AWS region for the EKS infrastructure"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Prefix used to name project resources"
  type        = string
  default     = "eks-gitops-platform"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used for public and private subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}


variable "kubernetes_version" {
  description = "Kubernetes version requested for the EKS cluster"
  type        = string
  default     = "1.34"
}
