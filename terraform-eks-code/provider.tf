# Define the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35.0"
    }
  }
}


# Backend Configuration (for S3)
terraform {
  backend "s3" {
    bucket = "devops-tfstate-hu2"  
    key    = "terraform.tfstate"          
    region = "us-east-1"              
  }
}



