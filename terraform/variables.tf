# terraform/variables.tf
variable "my_ip" {
  type        = string
  description = "Your public IP in CIDR format — e.g. 203.0.113.5/32"
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair you uploaded in Phase 0"
  default     = "gitops-deployer"
}
