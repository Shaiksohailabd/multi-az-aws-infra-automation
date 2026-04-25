terraform {
  backend "s3" {
    bucket = "qa-statefile-storage"
    key = "qa/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "qa-terraform-state-lock"
    encrypt = true
  }

  required_providers {
    aws = {
        source = "hashicrop/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags{
    tags{
        Environment = "QA"
        ManagedBy = "terraform"
    }
  }
}