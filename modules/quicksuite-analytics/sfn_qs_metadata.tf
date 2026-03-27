resource "aws_sfn_state_machine" "qs_metadata_sync" {
  name     = "quicksuite-qs-metadata-sync"
  role_arn = aws_iam_role.sfn_qs_metadata.arn

  definition = jsonencode({
    Comment = "Collect QuickSight metadata — datasets, dashboards, analyses, datasources, SPICE"
    StartAt = "CollectAll"
    States = {
      CollectAll = {
        Type = "Parallel"
        Branches = [
          # Branch 1: Datasets (List → Check → Distributed Map → Write)
          {
            StartAt = "ListDatasets"
            States = {
              ListDatasets = {
                Type     = "Task"
                Resource = aws_lambda_function.qs_list_datasets.arn
                Parameters = { "bucket" = aws_s3_bucket.quicksuite_logs.id }
                Retry    = local.lambda_retry
                Next     = "CheckDatasets"
              }
              CheckDatasets = {
                Type = "Choice"
                Choices = [{ Variable = "$.count", NumericGreaterThan = 0, Next = "DescribeDatasets" }]
                Default = "DatasetsSkip"
              }
              DatasetsSkip = { Type = "Succeed" }
              DescribeDatasets = {
                Type = "Map"
                ItemReader = {
                  Resource     = "arn:aws:states:::s3:getObject"
                  ReaderConfig = { InputType = "JSONL" }
                  Parameters   = { "Bucket.$" = "$.temp_bucket", "Key.$" = "$.temp_key" }
                }
                MaxConcurrency = 5
                ItemProcessor = {
                  ProcessorConfig = { Mode = "DISTRIBUTED", ExecutionType = "STANDARD" }
                  StartAt = "DescribeOneDataset"
                  States = {
                    DescribeOneDataset = {
                      Type     = "Task"
                      Resource = aws_lambda_function.qs_describe_dataset.arn
                      Retry = [{
                        ErrorEquals     = ["States.ALL"]
                        IntervalSeconds = 60
                        MaxAttempts     = 10
                        BackoffRate     = 2
                        MaxDelaySeconds = 3600
                      }]
                      End = true
                    }
                  }
                }
                ResultWriter = {
                  Resource   = "arn:aws:states:::s3:putObject"
                  Parameters = { Bucket = aws_s3_bucket.quicksuite_logs.id, Prefix = "temp/qs_results/datasets/" }
                }
                ToleratedFailurePercentage = 100
                ResultPath = "$.map_run"
                Next       = "WriteDatasets"
              }
              WriteDatasets = {
                Type     = "Task"
                Resource = aws_lambda_function.qs_write_metadata.arn
                Parameters = {
                  "map_run.$"         = "$.map_run"
                  "temp_bucket.$"     = "$.temp_bucket"
                  "parser_temp_key.$" = "$.temp_key"
                  "output_prefix"     = "qs_metadata/datasets/"
                }
                Retry = local.lambda_retry
                End   = true
              }
            }
          },
          # Branch 2: Dashboards (List → Check → Distributed Map → Write)
          {
            StartAt = "ListDashboards"
            States = {
              ListDashboards = {
                Type     = "Task"
                Resource = aws_lambda_function.qs_list_dashboards.arn
                Parameters = { "bucket" = aws_s3_bucket.quicksuite_logs.id }
                Retry    = local.lambda_retry
                Next     = "CheckDashboards"
              }
              CheckDashboards = {
                Type = "Choice"
                Choices = [{ Variable = "$.count", NumericGreaterThan = 0, Next = "DescribeDashboards" }]
                Default = "DashboardsSkip"
              }
              DashboardsSkip = { Type = "Succeed" }
              DescribeDashboards = {
                Type = "Map"
                ItemReader = {
                  Resource     = "arn:aws:states:::s3:getObject"
                  ReaderConfig = { InputType = "JSONL" }
                  Parameters   = { "Bucket.$" = "$.temp_bucket", "Key.$" = "$.temp_key" }
                }
                MaxConcurrency = 5
                ItemProcessor = {
                  ProcessorConfig = { Mode = "DISTRIBUTED", ExecutionType = "STANDARD" }
                  StartAt = "DescribeOneDashboard"
                  States = {
                    DescribeOneDashboard = {
                      Type     = "Task"
                      Resource = aws_lambda_function.qs_describe_dashboard.arn
                      Retry = [{
                        ErrorEquals     = ["States.ALL"]
                        IntervalSeconds = 60
                        MaxAttempts     = 10
                        BackoffRate     = 2
                        MaxDelaySeconds = 3600
                      }]
                      End = true
                    }
                  }
                }
                ResultWriter = {
                  Resource   = "arn:aws:states:::s3:putObject"
                  Parameters = { Bucket = aws_s3_bucket.quicksuite_logs.id, Prefix = "temp/qs_results/dashboards/" }
                }
                ToleratedFailurePercentage = 100
                ResultPath = "$.map_run"
                Next       = "WriteDashboards"
              }
              WriteDashboards = {
                Type     = "Task"
                Resource = aws_lambda_function.qs_write_metadata.arn
                Parameters = {
                  "map_run.$"         = "$.map_run"
                  "temp_bucket.$"     = "$.temp_bucket"
                  "parser_temp_key.$" = "$.temp_key"
                  "output_prefix"     = "qs_metadata/dashboards/"
                }
                Retry = local.lambda_retry
                End   = true
              }
            }
          },
          # Branch 3: Analyses (List → Check → Distributed Map → Write)
          {
            StartAt = "ListAnalyses"
            States = {
              ListAnalyses = {
                Type     = "Task"
                Resource = aws_lambda_function.qs_list_analyses.arn
                Parameters = { "bucket" = aws_s3_bucket.quicksuite_logs.id }
                Retry    = local.lambda_retry
                Next     = "CheckAnalyses"
              }
              CheckAnalyses = {
                Type = "Choice"
                Choices = [{ Variable = "$.count", NumericGreaterThan = 0, Next = "DescribeAnalyses" }]
                Default = "AnalysesSkip"
              }
              AnalysesSkip = { Type = "Succeed" }
              DescribeAnalyses = {
                Type = "Map"
                ItemReader = {
                  Resource     = "arn:aws:states:::s3:getObject"
                  ReaderConfig = { InputType = "JSONL" }
                  Parameters   = { "Bucket.$" = "$.temp_bucket", "Key.$" = "$.temp_key" }
                }
                MaxConcurrency = 5
                ItemProcessor = {
                  ProcessorConfig = { Mode = "DISTRIBUTED", ExecutionType = "STANDARD" }
                  StartAt = "DescribeOneAnalysis"
                  States = {
                    DescribeOneAnalysis = {
                      Type     = "Task"
                      Resource = aws_lambda_function.qs_describe_analysis.arn
                      Retry = [{
                        ErrorEquals     = ["States.ALL"]
                        IntervalSeconds = 60
                        MaxAttempts     = 10
                        BackoffRate     = 2
                        MaxDelaySeconds = 3600
                      }]
                      End = true
                    }
                  }
                }
                ResultWriter = {
                  Resource   = "arn:aws:states:::s3:putObject"
                  Parameters = { Bucket = aws_s3_bucket.quicksuite_logs.id, Prefix = "temp/qs_results/analyses/" }
                }
                ToleratedFailurePercentage = 100
                ResultPath = "$.map_run"
                Next       = "WriteAnalyses"
              }
              WriteAnalyses = {
                Type     = "Task"
                Resource = aws_lambda_function.qs_write_metadata.arn
                Parameters = {
                  "map_run.$"         = "$.map_run"
                  "temp_bucket.$"     = "$.temp_bucket"
                  "parser_temp_key.$" = "$.temp_key"
                  "output_prefix"     = "qs_metadata/analyses/"
                }
                Retry = local.lambda_retry
                End   = true
              }
            }
          },
          # Branch 4: Datasources (single Lambda)
          {
            StartAt = "CollectDatasources"
            States = {
              CollectDatasources = {
                Type     = "Task"
                Resource = aws_lambda_function.qs_collect_datasources.arn
                Parameters = { "bucket" = aws_s3_bucket.quicksuite_logs.id }
                Retry    = local.lambda_retry
                End      = true
              }
            }
          },
          # Branch 5: SPICE (single Lambda)
          {
            StartAt = "CollectSpice"
            States = {
              CollectSpice = {
                Type     = "Task"
                Resource = aws_lambda_function.qs_collect_spice.arn
                Parameters = { "bucket" = aws_s3_bucket.quicksuite_logs.id }
                Retry    = local.lambda_retry
                End      = true
              }
            }
          }
        ]
        End = true
      }
    }
  })
}
