terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.0"
    }
  }

  backend "s3" {
    bucket         = "tf-state-devops-recipe-api"
    key            = "tf-state-setup"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "tf-lock-devops-recipe-app-api"
  }
}

provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Environment = terraform.workspace
      Project     = var.project
      contact     = var.contact
      ManagedBy   = "Terraform/setup"
    }
  }

}