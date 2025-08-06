terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "terraformbackendbartd"
    key            = "terraform.tfstate"
    region         = var.aws_region
    use_lockfile   = true
  }
}

provider "aws" {
  region = var.aws_region
}
