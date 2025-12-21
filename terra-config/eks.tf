############################################
# EKS Control Plane Subnets (Supported AZs)
############################################
data "aws_subnets" "eks_control_plane" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }

  filter {
    name   = "availability-zone"
    values = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c",
      "us-east-1d",
      "us-east-1f"
    ]
  }

  # Change to "private" if using private subnets
  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}

############################################
# Create the EKS Cluster
############################################
resource "aws_eks_cluster" "eks_cluster" {
  name       = "Three-tier-cloud"
  role_arn  = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids              = data.aws_subnets.eks_control_plane.ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}
