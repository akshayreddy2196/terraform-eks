
# Provider configuration for Kubernetes
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "akshay-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "sreekanth-vpc"
  }
}

# Security Group for Node Group
resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for all worker nodes in the cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow all node-to-node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-sg"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.2"

  name               = "akshay-eks-cluster"         
  kubernetes_version = "1.29"                       

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true   

  
  cluster_endpoint_public_access  = true   # Allow GitHub Actions to access API
  cluster_endpoint_private_access = fals


  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"    
      disk_size      = 20
      enable_node_auto_repair = true

      tags = {
        Name = "default-node-group"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# Add-ons


resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "kube-proxy"
  addon_version = "v1.29.0-eksbuild.1"
}

# ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name                 = "akshay-ecr-repo"
  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = "dev"
  }
}







