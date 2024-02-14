terraform {

  required_version = "~> 1.5"

  backend "s3" {
  bucket         = "io.snapsoft-sensible-test-bucket-matyas"
  key            = "sensible-infra/terraform.tfstate"
  region         = "eu-central-1"
  encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }
  }
}

