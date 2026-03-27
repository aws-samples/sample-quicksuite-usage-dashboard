resource "aws_iam_role_policy" "quicksight_cloudtrail_access" {
  count = var.cloudtrail_mode == "existing" ? 1 : 0
  name  = "QuickSightCloudTrailAccess-quicksuite"
  role  = var.quicksight_service_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:GetBucketLocation", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::${var.cloudtrail_s3_bucket}",
        "arn:aws:s3:::${var.cloudtrail_s3_bucket}/*"
      ]
    }]
  })
}
