terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # In a real environment, uncomment and configure an S3 backend for state locking
  # backend "s3" {
  #   bucket         = "devsecops-terraform-state"
  #   key            = "eks/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "DevSecOps-Platform"
      ManagedBy   = "Terraform"
    }
  }
}