terraform {
  backend "s3" {
    bucket         = "prod-statefile-storage"
    key            = "prod/terraform.tfstate"
    region         = var.region
    dynamodb_table = "prod-terraform-state-lock"
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
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}