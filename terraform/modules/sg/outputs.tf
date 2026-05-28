# terraform/modules/sg/outputs.tf
output "sg_id" { value = aws_security_group.k3s.id }
