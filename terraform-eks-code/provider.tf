# Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Backend Configuration (for S3)
terraform {
  backend "s3" {
    bucket = "devops-tfstate-hu2"  
    key    = "terraform.tfstate"          
    region = "us-east-1"              
  }
}
