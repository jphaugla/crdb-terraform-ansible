terraform {
  /* Uncomment this block to use Terraform Cloud for this tutorial
  cloud {
      organization = "organization-name"
      workspaces {
        name = "learn-terraform-expressions"
      }
  }
  */

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~> 4.7.0"
      version = ">= 5.0.0"
    }
  }

  required_version = ">= 1.2.0"
}
