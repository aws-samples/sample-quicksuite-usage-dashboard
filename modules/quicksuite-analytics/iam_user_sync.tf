# Lambda User Sync Role (shared by all 4 user sync Lambda functions)
resource "aws_iam_role" "lambda_user_sync" {
  name = "quicksuite-lambda-user-sync-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "user_sync_lambda_basic" {
  role       = aws_iam_role.lambda_user_sync.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "user_sync_lambda_permissions" {
  name = "quicksuite-user-sync-lambda-permissions"
  role = aws_iam_role.lambda_user_sync.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "identitystore:ListUsers",
          "identitystore:DescribeUser",
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["quicksight:ListUsers"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetPartitions",
        ]
        Resource = "*"
      },
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
    }] : [])
  })
}

# Step Functions User Sync Role
resource "aws_iam_role" "sfn_user_sync" {
  name = "quicksuite-sfn-user-sync-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "sfn_user_sync_permissions" {
  name = "quicksuite-sfn-user-sync-permissions"
  role = aws_iam_role.sfn_user_sync.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          aws_lambda_function.user_idc_list.arn,
          aws_lambda_function.user_idc_describe.arn,
          aws_lambda_function.user_qs_list.arn,
          aws_lambda_function.user_merge.arn,
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${aws_s3_bucket.quicksuite_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution",
          "states:DescribeExecution",
          "states:StopExecution",
        ]
        Resource = "*"
      }
    ], var.s3_kms_key_arn != null ? [{
      Effect   = "Allow"
      Action   = ["kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
      Resource = var.s3_kms_key_arn
    }] : [])
  })
}

# EventBridge User Sync Role
resource "aws_iam_role" "eventbridge_user_sync" {
  name = "quicksuite-eventbridge-user-sync-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_user_sync_permissions" {
  name = "quicksuite-eventbridge-user-sync-permissions"
  role = aws_iam_role.eventbridge_user_sync.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "states:StartExecution"
      Resource = aws_sfn_state_machine.user_sync.arn
    }]
  })
}
