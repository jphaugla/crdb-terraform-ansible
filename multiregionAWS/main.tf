# TODO:
# Single Region Cluster

provider "aws" {
  region = var.aws_region_list[0]
  alias = "region-0"
}

provider "aws" {
  region = var.aws_region_list[1]
  alias = "region-1"
}

provider "aws" {
  region = var.aws_region_list[2]
  alias = "region-2"
}

locals {
  required_tags = {
    owner       = var.owner,
    project     = var.project_name,
    environment = var.environment
  }
  tags = merge(var.resource_tags, local.required_tags)
}
