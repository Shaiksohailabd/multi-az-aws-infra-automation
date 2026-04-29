terraform {
  backend "s3" {
    bucket         = "dev-statefile-storage"
    key            = "dev/terraform.tfstate"
    region         = var.region
    dynamodb_table = "dev-terraform-state-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}