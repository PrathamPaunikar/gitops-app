# terraform/modules/sg/main.tf
resource "aws_security_group" "k3s" {
  name        = "${var.name}-k3s-sg"
  description = "Security group for k3s cluster nodes"
  vpc_id      = var.vpc_id

  # SSH — your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "SSH from my IP"
  }

  # k3s API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"

    cidr_blocks = [
      var.my_ip,
      "10.0.0.0/16"
    ]

    description = "k3s API access"
  }

  # App traffic (NodePort range for NGINX + ArgoCD)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort services"
  }

  # HTTP/HTTPS
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flannel VXLAN — inter-node only
  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Flannel VXLAN"
  }

  # Kubelet
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Kubelet"
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-k3s-sg" }
}
