############################################
# Default VPC
############################################
data "aws_vpc" "default" {
  default = true
}

############################################
# Public Subnets in Supported AZs (for optional public worker nodes)
############################################
data "aws_subnets" "public" {
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

  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}

############################################
# Private Subnets in Supported AZs (for EKS control plane & node groups)
############################################
data "aws_subnets" "private" {
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

  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}
