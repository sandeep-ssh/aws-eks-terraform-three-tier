############################################
# Launch Template for Node Group
############################################
resource "aws_launch_template" "eks_node_launch_template" {
  name = "${aws_eks_cluster.eks_cluster.name}-node-template"

  instance_type = "t3.medium"  # better baseline instance

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = "${aws_eks_cluster.eks_cluster.name}-node-template"
  }

  lifecycle {
    create_before_destroy = true
  }
}

############################################
# EKS Node Group
############################################
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.nodegroup_role.arn

  # Use private subnets in supported AZs
  subnet_ids = data.aws_subnets.eks_control_plane.ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.eks_node_launch_template.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
    aws_launch_template.eks_node_launch_template,
  ]
}
