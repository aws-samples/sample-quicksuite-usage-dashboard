# Lambda archives for user sync functions
data "archive_file" "user_idc_list" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/user_idc_list"
  output_path = "${path.module}/lambda/user_idc_list.zip"
}

data "archive_file" "user_idc_describe" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/user_idc_describe"
  output_path = "${path.module}/lambda/user_idc_describe.zip"
}

data "archive_file" "user_qs_list" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/user_qs_list"
  output_path = "${path.module}/lambda/user_qs_list.zip"
}

data "archive_file" "user_merge" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/user_merge"
  output_path = "${path.module}/lambda/user_merge.zip"
}

# User sync Lambda functions
resource "aws_lambda_function" "user_idc_list" {
  filename         = data.archive_file.user_idc_list.output_path
  function_name    = "quicksuite-user-idc-list"
  role             = aws_iam_role.lambda_user_sync.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [local.lambda_layer_arn]
  timeout          = 60
  memory_size      = 1024
  source_code_hash = data.archive_file.user_idc_list.output_base64sha256

  environment {
    variables = merge({
      IDENTITY_STORE_ID = var.identity_store_id
      BUCKET            = aws_s3_bucket.quicksuite_logs.id
    }, var.identity_store_role_arn != null ? {
      IDENTITY_STORE_ROLE_ARN = var.identity_store_role_arn
    } : {})
  }
}

resource "aws_lambda_function" "user_idc_describe" {
  filename         = data.archive_file.user_idc_describe.output_path
  function_name    = "quicksuite-user-idc-describe"
  role             = aws_iam_role.lambda_user_sync.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [local.lambda_layer_arn]
  timeout          = 30
  memory_size      = 256
  source_code_hash = data.archive_file.user_idc_describe.output_base64sha256

  environment {
    variables = merge({
      IDENTITY_STORE_ID = var.identity_store_id
      BUCKET            = aws_s3_bucket.quicksuite_logs.id
    }, var.identity_store_role_arn != null ? {
      IDENTITY_STORE_ROLE_ARN = var.identity_store_role_arn
    } : {})
  }
}

resource "aws_lambda_function" "user_qs_list" {
  filename         = data.archive_file.user_qs_list.output_path
  function_name    = "quicksuite-user-qs-list"
  role             = aws_iam_role.lambda_user_sync.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [local.lambda_layer_arn]
  timeout          = 60
  memory_size      = 256
  source_code_hash = data.archive_file.user_qs_list.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "user_merge" {
  filename         = data.archive_file.user_merge.output_path
  function_name    = "quicksuite-user-merge"
  role             = aws_iam_role.lambda_user_sync.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [local.lambda_layer_arn]
  timeout          = 300
  memory_size      = 2048
  source_code_hash = data.archive_file.user_merge.output_base64sha256

  environment {
    variables = {
      BUCKET            = aws_s3_bucket.quicksuite_logs.id
      OUTPUT_KEY        = "user_attributes/users.jsonl"
      DATABASE          = aws_glue_catalog_database.quicksuite.name
      ATHENA_OUTPUT     = "s3://${aws_s3_bucket.quicksuite_logs.id}/athena-results/"
      TIER_POWER_MIN    = tostring(var.user_tier_config.power_min_messages)
      TIER_REGULAR_MIN  = tostring(var.user_tier_config.regular_min_messages)
      TIER_CASUAL_MIN   = tostring(var.user_tier_config.casual_min_messages)
      TIER_POWER_PCT    = tostring(var.user_tier_config.power_percentile)
      TIER_REGULAR_PCT  = tostring(var.user_tier_config.regular_percentile)
      TIER_DORMANT_DAYS = tostring(var.user_tier_config.dormant_days)
      TIER_CHURNED_DAYS = tostring(var.user_tier_config.churned_days)
    }
  }
}
