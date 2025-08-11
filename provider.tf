terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "terraformbackendbartd"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile   = true
  }
}

provider "aws" {
  region = var.aws_region
}
