variable "project_name" {
  description = "Prefix used to name network resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for the subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways for the lab network"
  type        = number
  default     = 1

  validation {
    condition = (
      var.nat_gateway_count >= 1 &&
      var.nat_gateway_count <= length(var.public_subnet_cidrs)
    )
    error_message = "NAT gateway count must be at least 1 and no greater than the number of public subnets."
  }
}
