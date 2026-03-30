output "bucket_name" {
  value = aws_s3_bucket.quicksuite_logs.id
}

output "bucket_arn" {
  value = aws_s3_bucket.quicksuite_logs.arn
}

output "dashboard_id" {
  value = aws_quicksight_dashboard.quicksuite.dashboard_id
}

output "user_sync_sfn_arn" {
  value = aws_sfn_state_machine.user_sync.arn
}

output "cloudtrail_cross_account_bucket_policy" {
  description = "Bucket policy statement to add to the logging account's CloudTrail bucket. Only populated when cloudtrail_mode = 'existing'. Run: terraform output -raw cloudtrail_cross_account_bucket_policy"
  value = var.cloudtrail_mode == "existing" && var.cloudtrail_config != null ? jsonencode({
    Sid    = "AllowQuickSuiteAthenaCrossAccount"
    Effect = "Allow"
    Principal = {
      AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.quicksight_service_role_name}"
    }
    Action = ["s3:GetObject", "s3:GetBucketLocation", "s3:ListBucket"]
    Resource = [
      "arn:aws:s3:::${var.cloudtrail_config.s3_bucket}",
      "arn:aws:s3:::${var.cloudtrail_config.s3_bucket}/${local.cloudtrail_prefix}/*"
    ]
  }) : null
}
