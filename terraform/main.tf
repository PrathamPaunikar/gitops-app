# terraform/main.tf
locals {
  name   = "gitops"
  region = "ap-south-2"
}

module "vpc" {
  source      = "./modules/vpc"
  name        = local.name
  cidr_block  = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
  region      = local.region
}

module "sg" {
  source = "./modules/sg"
  name   = local.name
  vpc_id = module.vpc.vpc_id
  my_ip  = var.my_ip
}

module "ec2" {
  source    = "./modules/ec2"
  name      = local.name
  subnet_id = module.vpc.public_subnet_id
  sg_id     = module.sg.sg_id
  key_name  = var.key_name
}
