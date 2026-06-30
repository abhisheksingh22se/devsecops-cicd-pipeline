module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Enable NAT Gateway for private subnets to reach the internet (e.g., to pull updates)
  enable_nat_gateway     = true
  single_nat_gateway     = true # Set to false in true Prod for Multi-AZ redundancy
  enable_dns_hostnames   = true

  # Tags required by EKS to discover subnets for Load Balancers (Ingress)
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Karpenter / Auto-scaling discovery tag
    "karpenter.sh/discovery" = var.cluster_name
  }
}