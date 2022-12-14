terraform {
  required_version = ">= 1.0.1"

  backend "s3" {
    bucket = "pattp-tf-state"
    key    = "playgroud/terraform.tfstate"
    region = "ap-southeast-1"

    dynamodb_table = "tf-locking"
    encrypt = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.72"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.10"
    }

    helm = {
      source = "hashicorp/helm"
      version = ">= 2.4.1"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}
