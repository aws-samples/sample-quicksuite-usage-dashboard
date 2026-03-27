provider "aws" {
  region  = "eu-west-1"
  profile = "quicksuite"
}

data "aws_ssoadmin_instances" "this" {}

module "quicksuite_analytics" {
  source = "./modules/quicksuite-analytics"

  quicksight_admin_group = "quicksuite-admin"
  identity_store_id      = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  cloudtrail_mode        = "new"

  categorization_config = {
    enabled         = true
    model_id        = "global.amazon.nova-2-lite-v1:0"
    bedrock_region  = "us-east-1"
    max_concurrency = 5
  }
}

output "bucket_name" {
  value = module.quicksuite_analytics.bucket_name
}

output "dashboard_id" {
  value = module.quicksuite_analytics.dashboard_id
}
