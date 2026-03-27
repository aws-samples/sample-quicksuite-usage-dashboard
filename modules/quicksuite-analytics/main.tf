terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  schedule_rate = {
    MINUTE15 = "rate(15 minutes)"
    MINUTE30 = "rate(30 minutes)"
    HOURLY   = "rate(1 hour)"
    HOURS6   = "rate(6 hours)"
    DAILY    = "rate(1 day)"
  }
}
