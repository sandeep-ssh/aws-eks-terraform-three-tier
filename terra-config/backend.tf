terraform {
  backend "s3" {
    bucket         = "sandeep-eks-terraform-three-tier"  # Change if the name already exists. 
    key            = "eks/terraform.tfstate"       
    region         = "us-east-1"                   
    encrypt        = true
  }
}