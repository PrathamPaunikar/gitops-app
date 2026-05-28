# terraform/modules/ec2/iam.tf
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k3s_node" {
  name               = "${var.name}-k3s-node-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.k3s_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_read" {
  role       = aws_iam_role.k3s_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_instance_profile" "k3s_node" {
  name = "${var.name}-k3s-instance-profile"
  role = aws_iam_role.k3s_node.name
}
