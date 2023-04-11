terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
      }
    }
}

# Using alias to define the priders for differnet regions
provider "aws" {
    region = "eu-west-2"
    alias = "region_1"
}

provider "aws" {
    region = "eu-west-1"
    alias = "region_2"
}

data "aws_region" "region_1" {
    provider = aws.region_1
}

data "aws_region" "region_2" {
    provider = aws.region_2
}

output "region_1" {
    value = data.aws_region.region_1
    description = "The details of the first region"
}

output "region_2" {
    value = data.aws_region.region_2
    description = "The details of the second region"
}
