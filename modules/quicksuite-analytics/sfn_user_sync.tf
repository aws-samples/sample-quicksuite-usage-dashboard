resource "aws_sfn_state_machine" "user_sync" {
  name     = "quicksuite-user-sync"
  role_arn = aws_iam_role.sfn_user_sync.arn
  type     = "STANDARD"

  definition = jsonencode({
    Comment = "Sync user attributes from IAM Identity Center and QuickSight"
    StartAt = "ListIDCUsers"
    States = {
      ListIDCUsers = {
        Type     = "Task"
        Resource = aws_lambda_function.user_idc_list.arn
        Retry    = local.lambda_retry
        Next     = "ListUsersParallel"
      }
      ListUsersParallel = {
        Type       = "Parallel"
        ResultPath = "$.parallel_result"
        Next       = "MergeUsers"
        Branches = [
          {
            StartAt = "DescribeIDCUsers"
            States = {
              DescribeIDCUsers = {
                Type           = "Map"
                MaxConcurrency = 10
                ToleratedFailurePercentage = 100
                ItemReader = {
                  Resource     = "arn:aws:states:::s3:getObject"
                  ReaderConfig = { InputType = "JSON" }
                  Parameters = {
                    Bucket  = aws_s3_bucket.quicksuite_logs.id
                    "Key.$" = "$.idc_list_key"
                  }
                }
                ItemProcessor = {
                  ProcessorConfig = {
                    Mode          = "DISTRIBUTED"
                    ExecutionType = "STANDARD"
                  }
                  StartAt = "DescribeSingleUser"
                  States = {
                    DescribeSingleUser = {
                      Type     = "Task"
                      Resource = aws_lambda_function.user_idc_describe.arn
                      Retry    = local.lambda_retry
                      End      = true
                    }
                  }
                }
                ResultPath = "$.describe_results"
                End        = true
              }
            }
          },
          {
            StartAt = "ListQuickSightUsers"
            States = {
              ListQuickSightUsers = {
                Type     = "Task"
                Resource = aws_lambda_function.user_qs_list.arn
                Retry    = local.lambda_retry
                End      = true
              }
            }
          }
        ]
      }
      MergeUsers = {
        Type     = "Task"
        Resource = aws_lambda_function.user_merge.arn
        Parameters = {
          "qs_list_key.$" = "$.parallel_result[1].qs_list_key"
        }
        Retry = local.lambda_retry
        End   = true
      }
    }
  })
}
