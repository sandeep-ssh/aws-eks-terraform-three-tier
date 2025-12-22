############################################
# Backend Configuration
############################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "sandeep-eks-terraform-three-tier"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

############################################
# AWS Provider
############################################
provider "aws" {
  region = "us-east-1"
}

############################################
# Default VPC
############################################
data "aws_vpc" "default" {
  default = true
}

############################################
# Subnets in Supported AZs
############################################
data "aws_subnets" "all_supported" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
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
}

# Minimum 2 subnets required for EKS control plane
locals {
  eks_subnet_ids = slice(data.aws_subnets.all_supported.ids, 0, 2)
}

############################################
# IAM Roles
############################################
# EKS Cluster Role
resource "aws_iam_role" "cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Node Group Role
resource "aws_iam_role" "nodegroup_role" {
  name = "eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "nodegroup_worker_policy" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "nodegroup_cni_policy" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "nodegroup_ecr_readonly" {
  role       = aws_iam_role.nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################################
# EKS Cluster
############################################
resource "aws_eks_cluster" "eks_cluster" {
  name      = "three-tier-cloud-eks"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids              = local.eks_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

############################################
# Launch Template
############################################
resource "aws_launch_template" "eks_node_launch_template" {
  name = "${aws_eks_cluster.eks_cluster.name}-node-template"

  instance_type = "t3.medium"

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
  subnet_ids      = data.aws_subnets.all_supported.ids

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
    aws_iam_role_policy_attachment.nodegroup_worker_policy,
    aws_iam_role_policy_attachment.nodegroup_cni_policy,
    aws_iam_role_policy_attachment.nodegroup_ecr_readonly,
    aws_launch_template.eks_node_launch_template
  ]
}

############################################
# ECR Public Repositories
############################################
resource "aws_ecrpublic_repository" "frontend" {
  repository_name = "three-tier-frontend"
}

resource "aws_ecrpublic_repository" "backend" {
  repository_name = "three-tier-backend"
}