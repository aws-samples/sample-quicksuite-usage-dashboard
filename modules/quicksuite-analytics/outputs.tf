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
