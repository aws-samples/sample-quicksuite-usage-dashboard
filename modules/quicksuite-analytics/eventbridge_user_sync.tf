resource "aws_cloudwatch_event_rule" "user_sync_schedule" {
  name                = "quicksuite-user-sync-schedule"
  schedule_expression = local.schedule_rate[var.user_sync_interval]
}

resource "aws_cloudwatch_event_target" "user_sync_sfn" {
  rule     = aws_cloudwatch_event_rule.user_sync_schedule.name
  arn      = aws_sfn_state_machine.user_sync.arn
  role_arn = aws_iam_role.eventbridge_user_sync.arn
  input    = jsonencode({ source = "schedule" })
}
