provider "aws" {
  region = "us-east-1"
}

data "aws_ssoadmin_instances" "this" {}

module "quicksuite_analytics" {
  source = "../../modules/quicksuite-analytics"

  quicksight_admin_group = "qs-admins"
  identity_store_id      = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

output "bucket_name" {
  value = module.quicksuite_analytics.bucket_name
}

output "dashboard_id" {
  value = module.quicksuite_analytics.dashboard_id
}
