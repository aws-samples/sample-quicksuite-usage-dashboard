# Lambda archives for QS metadata sync functions
data "archive_file" "qs_list_datasets" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_list_datasets"
  output_path = "${path.module}/lambda/qs_list_datasets.zip"
}

data "archive_file" "qs_list_dashboards" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_list_dashboards"
  output_path = "${path.module}/lambda/qs_list_dashboards.zip"
}

data "archive_file" "qs_list_analyses" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_list_analyses"
  output_path = "${path.module}/lambda/qs_list_analyses.zip"
}

data "archive_file" "qs_describe_dataset" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_describe_dataset"
  output_path = "${path.module}/lambda/qs_describe_dataset.zip"
}

data "archive_file" "qs_describe_dashboard" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_describe_dashboard"
  output_path = "${path.module}/lambda/qs_describe_dashboard.zip"
}

data "archive_file" "qs_describe_analysis" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_describe_analysis"
  output_path = "${path.module}/lambda/qs_describe_analysis.zip"
}

data "archive_file" "qs_write_metadata" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_write_metadata"
  output_path = "${path.module}/lambda/qs_write_metadata.zip"
}

data "archive_file" "qs_collect_datasources" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_collect_datasources"
  output_path = "${path.module}/lambda/qs_collect_datasources.zip"
}

data "archive_file" "qs_collect_spice" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/qs_collect_spice"
  output_path = "${path.module}/lambda/qs_collect_spice.zip"
}

# QS metadata sync Lambda functions
resource "aws_lambda_function" "qs_list_datasets" {
  filename         = data.archive_file.qs_list_datasets.output_path
  function_name    = "quicksuite-qs-list-datasets"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 60
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_list_datasets.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "qs_list_dashboards" {
  filename         = data.archive_file.qs_list_dashboards.output_path
  function_name    = "quicksuite-qs-list-dashboards"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 60
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_list_dashboards.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "qs_list_analyses" {
  filename         = data.archive_file.qs_list_analyses.output_path
  function_name    = "quicksuite-qs-list-analyses"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 60
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_list_analyses.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "qs_describe_dataset" {
  filename         = data.archive_file.qs_describe_dataset.output_path
  function_name    = "quicksuite-qs-describe-dataset"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 90
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_describe_dataset.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "qs_describe_dashboard" {
  filename         = data.archive_file.qs_describe_dashboard.output_path
  function_name    = "quicksuite-qs-describe-dashboard"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 90
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_describe_dashboard.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "qs_describe_analysis" {
  filename         = data.archive_file.qs_describe_analysis.output_path
  function_name    = "quicksuite-qs-describe-analysis"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 90
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_describe_analysis.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "qs_write_metadata" {
  filename         = data.archive_file.qs_write_metadata.output_path
  function_name    = "quicksuite-qs-write-metadata"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 120
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_write_metadata.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "qs_collect_datasources" {
  filename         = data.archive_file.qs_collect_datasources.output_path
  function_name    = "quicksuite-qs-collect-datasources"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 300
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_collect_datasources.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}

resource "aws_lambda_function" "qs_collect_spice" {
  filename         = data.archive_file.qs_collect_spice.output_path
  function_name    = "quicksuite-qs-collect-spice"
  role             = aws_iam_role.lambda_qs_metadata.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [aws_lambda_layer_version.dependencies.arn]
  timeout          = 120
  memory_size      = var.qs_metadata_lambda_memory
  source_code_hash = data.archive_file.qs_collect_spice.output_base64sha256

  environment {
    variables = {
      BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}
