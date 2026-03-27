locals {
  quicksuite_arn = "arn:aws:quicksight:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:account/${data.aws_caller_identity.current.account_id}"
}

resource "aws_cloudwatch_log_delivery_source" "chat" {
  name         = "quicksuite-chat-logs"
  log_type     = "CHAT_LOGS"
  resource_arn = local.quicksuite_arn
}

resource "aws_cloudwatch_log_delivery_source" "feedback" {
  name         = "quicksuite-feedback-logs"
  log_type     = "FEEDBACK_LOGS"
  resource_arn = local.quicksuite_arn
}

resource "aws_cloudwatch_log_delivery_source" "agent_hours" {
  name         = "quicksuite-agent-hours-logs"
  log_type     = "AGENT_HOURS_LOGS"
  resource_arn = local.quicksuite_arn
}

resource "aws_cloudwatch_log_delivery_destination" "s3" {
  name = "quicksuite-logs-s3"
  delivery_destination_configuration {
    destination_resource_arn = aws_s3_bucket.quicksuite_logs.arn
  }
}

resource "aws_cloudwatch_log_delivery" "chat" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.chat.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3.arn
}

resource "aws_cloudwatch_log_delivery" "feedback" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.feedback.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3.arn
  depends_on               = [aws_cloudwatch_log_delivery.chat]
}

resource "aws_cloudwatch_log_delivery" "agent_hours" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agent_hours.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.s3.arn
  depends_on               = [aws_cloudwatch_log_delivery.feedback]
}
