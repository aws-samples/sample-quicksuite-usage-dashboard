locals {
  cloudtrail_enabled = var.cloudtrail_mode != "disabled"
  cloudtrail_bucket  = var.cloudtrail_mode == "new" ? aws_s3_bucket.quicksuite_logs.id : var.cloudtrail_s3_bucket
}

resource "aws_cloudtrail" "quicksuite" {
  count = var.cloudtrail_mode == "new" ? 1 : 0

  name                          = "quicksuite-asset-tracking"
  s3_bucket_name                = aws_s3_bucket.quicksuite_logs.id
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_logging                = true

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true
  }
}
