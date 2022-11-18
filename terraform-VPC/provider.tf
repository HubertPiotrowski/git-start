terraform {
   backend "s3" {
    bucket = "tf-state-hubert132487863"
    key    = "terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "tf-state"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
  allowed_account_ids = [
    "405263612440",
  ]
}
