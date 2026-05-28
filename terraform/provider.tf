# terraform/provider.tf
terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "gitops-tf-state-1779879182"
    key    = "gitops/terraform.tfstate"
    region = "ap-south-2"
  }
}

provider "aws" {
  region = "ap-south-2"
}
