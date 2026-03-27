# Lambda QS Metadata Role (shared by all 9 QS metadata Lambda functions)
resource "aws_iam_role" "lambda_qs_metadata" {
  name = "quicksuite-lambda-qs-metadata-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "qs_metadata_lambda_basic" {
  role       = aws_iam_role.lambda_qs_metadata.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "qs_metadata_lambda_permissions" {
  name = "quicksuite-qs-metadata-lambda-permissions"
  role = aws_iam_role.lambda_qs_metadata.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "quicksight:ListDataSets",
          "quicksight:DescribeDataSet",
          "quicksight:DescribeDataSetPermissions",
          "quicksight:ListIngestions",
          "quicksight:ListDashboards",
          "quicksight:DescribeDashboard",
          "quicksight:ListAnalyses",
          "quicksight:DescribeAnalysis",
          "quicksight:ListDataSources",
          "quicksight:DescribeDataSource",
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:GetMetricData"]
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

# Step Functions QS Metadata Role
resource "aws_iam_role" "sfn_qs_metadata" {
  name = "quicksuite-sfn-qs-metadata-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "sfn_qs_metadata_permissions" {
  name = "quicksuite-sfn-qs-metadata-permissions"
  role = aws_iam_role.sfn_qs_metadata.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          aws_lambda_function.qs_list_datasets.arn,
          aws_lambda_function.qs_list_dashboards.arn,
          aws_lambda_function.qs_list_analyses.arn,
          aws_lambda_function.qs_describe_dataset.arn,
          aws_lambda_function.qs_describe_dashboard.arn,
          aws_lambda_function.qs_describe_analysis.arn,
          aws_lambda_function.qs_write_metadata.arn,
          aws_lambda_function.qs_collect_datasources.arn,
          aws_lambda_function.qs_collect_spice.arn,
        ]
      },
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

# EventBridge QS Metadata Role
resource "aws_iam_role" "eventbridge_qs_metadata" {
  name = "quicksuite-eventbridge-qs-metadata-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_qs_metadata_permissions" {
  name = "quicksuite-eventbridge-qs-metadata-permissions"
  role = aws_iam_role.eventbridge_qs_metadata.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "states:StartExecution"
      Resource = aws_sfn_state_machine.qs_metadata_sync.arn
    }]
  })
}
