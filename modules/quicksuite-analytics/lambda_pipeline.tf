locals {
  lambda_layer_arn = var.lambda_layer_arn != null ? var.lambda_layer_arn : aws_lambda_layer_version.dependencies[0].arn
}

# Dependencies Layer (Docker build)
# Builds an ARM64 Lambda layer with shared dependencies. Requires Docker to be installed and running.
# The layer.zip is rebuilt when requirements.txt or Dockerfile change.
# Skipped when var.lambda_layer_arn is provided.
resource "null_resource" "dependencies_layer_build" {
  count = var.lambda_layer_arn == null ? 1 : 0
  triggers = {
    requirements = filemd5("${path.module}/lambda/dependencies_layer/requirements.txt")
    dockerfile   = filemd5("${path.module}/lambda/dependencies_layer/Dockerfile")
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-ec"]
    command = <<-EOT
      # Fail fast if Docker is not available
      if ! command -v docker &>/dev/null; then
        echo "ERROR: Docker is required to build the dependencies Lambda layer but was not found."
        echo "Install Docker: https://docs.docker.com/get-docker/"
        exit 1
      fi
      if ! docker info &>/dev/null; then
        echo "ERROR: Docker daemon is not running. Please start Docker and retry."
        exit 1
      fi

      cd ${path.module}/lambda/dependencies_layer
      docker build --platform linux/arm64 -t quicksuite-dependencies-layer .
      container_id=$(docker create quicksuite-dependencies-layer)
      rm -rf python layer.zip
      docker cp $container_id:/opt/python ./python
      docker rm $container_id
      zip -r layer.zip python -q
      rm -rf python

      # Verify the zip was created and is non-empty
      if [ ! -s layer.zip ]; then
        echo "ERROR: layer.zip was not created or is empty. Docker build may have failed."
        exit 1
      fi
      echo "SUCCESS: layer.zip built ($(du -h layer.zip | cut -f1))"
    EOT
  }
}

# Upload layer zip to S3 first (avoids 67MB direct upload limit for PublishLayerVersion)
resource "aws_s3_object" "dependencies_layer" {
  count  = var.lambda_layer_arn == null ? 1 : 0
  bucket = aws_s3_bucket.quicksuite_logs.id
  key    = "lambda-layers/dependencies-layer.zip"
  source = "${path.module}/lambda/dependencies_layer/layer.zip"
  etag   = fileexists("${path.module}/lambda/dependencies_layer/layer.zip") ? filemd5("${path.module}/lambda/dependencies_layer/layer.zip") : "pending-build"

  depends_on = [null_resource.dependencies_layer_build]
}

resource "aws_lambda_layer_version" "dependencies" {
  count               = var.lambda_layer_arn == null ? 1 : 0
  s3_bucket           = aws_s3_object.dependencies_layer[0].bucket
  s3_key              = aws_s3_object.dependencies_layer[0].key
  s3_object_version   = aws_s3_object.dependencies_layer[0].version_id
  layer_name          = "quicksuite-dependencies"
  compatible_runtimes = ["python3.14"]
  source_code_hash    = fileexists("${path.module}/lambda/dependencies_layer/layer.zip") ? filebase64sha256("${path.module}/lambda/dependencies_layer/layer.zip") : "pending-build"
  description         = "Shared dependencies: boto3 + pyarrow"
  depends_on          = [aws_s3_object.dependencies_layer]
}

# Lambda archives
data "archive_file" "sfn_trigger" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/sfn_trigger"
  output_path = "${path.module}/lambda/sfn_trigger.zip"
}

data "archive_file" "parser" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/parser"
  output_path = "${path.module}/lambda/parser.zip"
}

data "archive_file" "categorizer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/categorizer"
  output_path = "${path.module}/lambda/categorizer.zip"
}

data "archive_file" "writer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/writer"
  output_path = "${path.module}/lambda/writer.zip"
}

# Lambda functions
resource "aws_lambda_function" "trigger" {
  filename         = data.archive_file.sfn_trigger.output_path
  function_name    = "quicksuite-sfn-trigger"
  role             = aws_iam_role.lambda_trigger.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [local.lambda_layer_arn]
  timeout          = 10
  source_code_hash = data.archive_file.sfn_trigger.output_base64sha256

  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.log_analytics.arn
    }
  }
}

resource "aws_lambda_function" "parser" {
  filename         = data.archive_file.parser.output_path
  function_name    = "quicksuite-log-parser"
  role             = aws_iam_role.lambda_pipeline.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [local.lambda_layer_arn]
  timeout          = 60
  source_code_hash = data.archive_file.parser.output_base64sha256
}

resource "aws_lambda_function" "categorizer" {
  filename         = data.archive_file.categorizer.output_path
  function_name    = "quicksuite-message-categorizer"
  role             = aws_iam_role.lambda_pipeline.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [local.lambda_layer_arn]
  timeout          = 90
  source_code_hash = data.archive_file.categorizer.output_base64sha256

  environment {
    variables = {
      CATEGORIZATION_ENABLED = tostring(var.categorization_config.enabled)
      DYNAMODB_TABLE         = var.categorization_config.enabled ? aws_dynamodb_table.categorizer_config[0].name : "disabled"
      CONFIG_ID              = "default"
      MODEL_ID               = var.categorization_config.model_id
      BEDROCK_REGION         = var.categorization_config.bedrock_region
    }
  }
}

resource "aws_lambda_function" "writer" {
  filename         = data.archive_file.writer.output_path
  function_name    = "quicksuite-result-writer"
  role             = aws_iam_role.lambda_pipeline.arn
  handler          = "index.handler"
  runtime          = "python3.14"
  architectures    = ["arm64"]
  layers           = [local.lambda_layer_arn]
  timeout          = 60
  source_code_hash = data.archive_file.writer.output_base64sha256

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.quicksuite_logs.id
    }
  }
}
