terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # ensures compatibility with Terraform AWS provider v5.x
    }
  }

  required_version = ">= 1.5.0"  # optional, ensures Terraform CLI version is compatible
}

# Configure the AWS Provider
provider "aws" {
  region                  = "us-east-1"
  allowed_account_ids     = []       # optional: restrict to your AWS account
  shared_credentials_file = "~/.aws/credentials"  # optional: explicit credentials file
  profile                 = "default"             # optional: AWS CLI profile
  # max_retries           = 5                     # optional: retry on transient failures
}
