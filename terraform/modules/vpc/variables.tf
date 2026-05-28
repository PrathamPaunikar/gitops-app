# terraform/modules/vpc/variables.tf
variable "name"        { type = string }
variable "cidr_block"  { type = string }
variable "subnet_cidr" { type = string }
variable "region"      { type = string }
