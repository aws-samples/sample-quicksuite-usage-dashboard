# S3 event notification to Lambda trigger.
# Named eventbridge.tf for consistency with old project and because future
# features (user sync) will add EventBridge rules to this file.
resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.quicksuite_logs.arn
}

resource "aws_s3_bucket_notification" "logs" {
  bucket = aws_s3_bucket.quicksuite_logs.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
  }

  depends_on = [aws_lambda_permission.s3_trigger]
}
