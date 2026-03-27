locals {
  bucket_name = "${data.aws_caller_identity.current.account_id}-quicksuite-logs"
}

resource "aws_s3_bucket" "quicksuite_logs" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "quicksuite_logs" {
  bucket = aws_s3_bucket.quicksuite_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "quicksuite_logs" {
  bucket = aws_s3_bucket.quicksuite_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.s3_kms_key_arn
    }
    bucket_key_enabled = var.s3_kms_key_arn != null
  }
}

resource "aws_s3_bucket_public_access_block" "quicksuite_logs" {
  bucket                  = aws_s3_bucket.quicksuite_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "quicksuite_logs" {
  bucket = aws_s3_bucket.quicksuite_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.quicksuite_logs.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.quicksuite_logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ],
    var.cloudtrail_mode == "new" ? [{
      Sid    = "AWSCloudTrailWrite"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.quicksuite_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl" = "bucket-owner-full-control"
        }
      }
    }] : [],
    var.cloudtrail_mode == "new" ? [{
      Sid    = "AWSCloudTrailAclCheck"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:GetBucketAcl"
      Resource = aws_s3_bucket.quicksuite_logs.arn
    }] : [],
    [{
      Sid       = "DenyPIIGetObject"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource = [
        "${aws_s3_bucket.quicksuite_logs.arn}/AWSLogs/*",
        "${aws_s3_bucket.quicksuite_logs.arn}/temp/*",
      ]
      Condition = {
        StringNotLike = {
          "aws:PrincipalArn" = [
            aws_iam_role.lambda_pipeline.arn,
            aws_iam_role.lambda_qs_metadata.arn,
            aws_iam_role.sfn.arn,
            aws_iam_role.sfn_qs_metadata.arn,
          ]
        }
      }
    },
    {
      Sid       = "DenyPIIListBucket"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:ListBucket"
      Resource  = aws_s3_bucket.quicksuite_logs.arn
      Condition = {
        StringLike = {
          "s3:prefix" = ["AWSLogs/*", "temp/*"]
        }
        StringNotLike = {
          "aws:PrincipalArn" = [
            aws_iam_role.lambda_pipeline.arn,
            aws_iam_role.lambda_qs_metadata.arn,
            aws_iam_role.sfn.arn,
            aws_iam_role.sfn_qs_metadata.arn,
          ]
        }
      }
    }]
  )
  })
}
