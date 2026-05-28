# terraform/outputs.tf
output "master_public_ip" { value = module.ec2.master_public_ip }
output "worker_public_ip" { value = module.ec2.worker_public_ip }
output "kubeconfig_cmd" {
  value = "scp -i ~/1199/self-managed-k8s/creds/gitops-deployer ubuntu@16.112.60.3:/etc/rancher/k3s/k3s.yaml ~/.kube/k3s-config"
}
