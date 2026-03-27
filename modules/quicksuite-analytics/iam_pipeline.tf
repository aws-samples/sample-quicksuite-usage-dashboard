# Lambda Trigger Role (starts Step Functions)
resource "aws_iam_role" "lambda_trigger" {
  name = "quicksuite-lambda-trigger-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "trigger_basic" {
  role       = aws_iam_role.lambda_trigger.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "trigger_sfn" {
  name = "quicksuite-trigger-sfn"
  role = aws_iam_role.lambda_trigger.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "states:StartExecution"
      Resource = aws_sfn_state_machine.log_analytics.arn
    }]
  })
}

# Lambda Pipeline Role (shared by parser, categorizer, writer)
resource "aws_iam_role" "lambda_pipeline" {
  name = "quicksuite-lambda-pipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_basic" {
  role       = aws_iam_role.lambda_pipeline.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "pipeline_permissions" {
  name = "quicksuite-pipeline-permissions"
  role = aws_iam_role.lambda_pipeline.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.quicksuite_logs.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = aws_s3_bucket.quicksuite_logs.arn
      }
    ], var.s3_kms_key_arn != null ? [{
      Effect   = "Allow"
      Action   = ["kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
      Resource = var.s3_kms_key_arn
    }] : [], var.categorization_config.enabled ? [
      {
        Effect   = "Allow"
        Action   = "bedrock:InvokeModel"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "dynamodb:GetItem"
        Resource = aws_dynamodb_table.categorizer_config[0].arn
      }
    ] : [])
  })
}

# Step Functions Role
resource "aws_iam_role" "sfn" {
  name = "quicksuite-sfn-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "sfn_permissions" {
  name = "quicksuite-sfn-permissions"
  role = aws_iam_role.sfn.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([{
      Effect = "Allow"
      Action = "lambda:InvokeFunction"
      Resource = [
        aws_lambda_function.parser.arn,
        aws_lambda_function.categorizer.arn,
        aws_lambda_function.writer.arn,
      ]
    }], var.categorization_config.enabled ? [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${aws_s3_bucket.quicksuite_logs.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.quicksuite_logs.arn
      },
      {
        Effect   = "Allow"
        Action   = ["states:StartExecution", "states:DescribeExecution", "states:StopExecution"]
        Resource = aws_sfn_state_machine.log_analytics.arn
      }
    ] : [])
  })
}

# QuickSight S3 access policy
resource "aws_iam_role_policy" "quicksight_s3_access" {
  name = "QuickSightS3Access-quicksuite"
  role = var.quicksight_service_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:GetBucketLocation", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.quicksuite_logs.arn,
          "${aws_s3_bucket.quicksuite_logs.arn}/*",
        ]
      }
    ], var.s3_kms_key_arn != null ? [{
      Effect   = "Allow"
      Action   = ["kms:Decrypt", "kms:DescribeKey"]
      Resource = var.s3_kms_key_arn
    }] : [])
  })
}
