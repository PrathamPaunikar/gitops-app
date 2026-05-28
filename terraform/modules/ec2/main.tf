# terraform/modules/ec2/main.tf

# Fetch latest Ubuntu 22.04 AMI for ap-south-2
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]   # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Master node
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.k3s_node.name

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    apt-get update -y
    apt-get install -y awscli

    # Install k3s (disable traefik — we'll use NGINX Ingress)
    curl -sfL https://get.k3s.io | sh -s - \
      --write-kubeconfig-mode 644 \
      --disable traefik

    # Wait for k3s to be ready
    sleep 15

    # Store node token in SSM for worker to fetch
    TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
    aws ssm put-parameter \
      --name "/k3s/node-token" \
      --value "$TOKEN" \
      --type SecureString \
      --region ap-south-2 \
      --overwrite
  EOF

  tags = { Name = "${var.name}-k3s-master", Role = "master" }
}

# Worker node
resource "aws_instance" "worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.k3s_node.name

  # Worker must start after master has written the token
  depends_on = [aws_instance.master]

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    apt-get update -y
    apt-get install -y awscli

    # Wait for master to write token to SSM
    sleep 45

    # Fetch token from SSM
    TOKEN=$(aws ssm get-parameter \
      --name "/k3s/node-token" \
      --with-decryption \
      --query "Parameter.Value" \
      --output text \
      --region ap-south-2)

    # Join the cluster
    curl -sfL https://get.k3s.io | \
      K3S_URL=https://${aws_instance.master.private_ip}:6443 \
      K3S_TOKEN=$TOKEN sh -
  EOF

  tags = { Name = "${var.name}-k3s-worker", Role = "worker" }
}
