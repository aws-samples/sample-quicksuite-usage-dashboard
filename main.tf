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
  s3_kms_key_arn         = "arn:aws:kms:eu-west-1:473649005621:key/0795532b-ce88-4e14-8136-42eedcf5fac7"

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

output "cloudtrail_cross_account_bucket_policy" {
  value = module.quicksuite_analytics.cloudtrail_cross_account_bucket_policy
}
