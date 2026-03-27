resource "aws_cloudwatch_event_rule" "qs_metadata_schedule" {
  name                = "quicksuite-qs-metadata-sync-schedule"
  schedule_expression = local.schedule_rate[var.qs_metadata_sync_interval]
}

resource "aws_cloudwatch_event_target" "qs_metadata_sfn" {
  rule     = aws_cloudwatch_event_rule.qs_metadata_schedule.name
  arn      = aws_sfn_state_machine.qs_metadata_sync.arn
  role_arn = aws_iam_role.eventbridge_qs_metadata.arn
  input    = jsonencode({ source = "schedule", bucket = aws_s3_bucket.quicksuite_logs.id })
}
