# Define the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 1.31"
    }
  }
   required_version = ">= 1.5.7"
}


# Backend Configuration (for S3)
terraform {
  backend "s3" {
    bucket = "devops-tfstate-hu2"  
    key    = "terraform.tfstate"          
    region = "us-east-1"              
  }
}






