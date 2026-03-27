locals {
  lambda_retry = [{
    ErrorEquals     = ["States.TaskFailed", "States.Timeout", "Lambda.ServiceException", "Lambda.TooManyRequestsException"]
    IntervalSeconds = 2
    MaxAttempts     = 3
    BackoffRate     = 2
  }]
}

resource "aws_sfn_state_machine" "log_analytics" {
  name     = "quicksuite-log-analytics"
  role_arn = aws_iam_role.sfn.arn

  definition = var.categorization_config.enabled ? jsonencode({
    Comment = "Process QuickSuite logs — parse, categorize (Bedrock Distributed Map), write Parquet"
    StartAt = "ParseLogFile"
    States = {
      ParseLogFile = {
        Type     = "Task"
        Resource = aws_lambda_function.parser.arn
        Retry    = local.lambda_retry
        Next     = "CheckChatMessages"
      }
      CheckChatMessages = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.chat_count"
          NumericGreaterThan = 0
          Next               = "CategorizeMessages"
        }]
        Default = "CheckResourceSelections"
      }
      CategorizeMessages = {
        Type = "Map"
        ItemReader = {
          Resource = "arn:aws:states:::s3:getObject"
          ReaderConfig = { InputType = "JSONL" }
          Parameters = {
            "Bucket.$" = "$.temp_bucket"
            "Key.$"    = "$.chat_temp_key"
          }
        }
        MaxConcurrency = var.categorization_config.max_concurrency
        ItemProcessor = {
          ProcessorConfig = {
            Mode          = "DISTRIBUTED"
            ExecutionType = "STANDARD"
          }
          StartAt = "Categorize"
          States = {
            Categorize = {
              Type     = "Task"
              Resource = aws_lambda_function.categorizer.arn
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
          Resource = "arn:aws:states:::s3:putObject"
          Parameters = {
            Bucket = aws_s3_bucket.quicksuite_logs.id
            Prefix = "temp/results/"
          }
        }
        ToleratedFailurePercentage = 100
        ResultPath                 = "$.map_run"
        Next                       = "WriteChatResults"
      }
      WriteChatResults = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "map_run.$"         = "$.map_run"
          "source_key.$"      = "$.source_key"
          "temp_bucket.$"     = "$.temp_bucket"
          "parser_temp_key.$" = "$.chat_temp_key"
          "output_prefix"     = "enriched/"
        }
        ResultPath = "$.chat_write_result"
        Retry      = local.lambda_retry
        Next       = "CheckResourceSelections"
      }
      CheckResourceSelections = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.resource_selections_count"
          NumericGreaterThan = 0
          Next               = "WriteResourceSelections"
        }]
        Default = "CheckPluginUtilization"
      }
      WriteResourceSelections = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.resource_selections_temp_key"
          "source_key.$"  = "$.source_key"
          "output_prefix" = "enriched_resource_selections/"
        }
        ResultPath = "$.resource_selections_write_result"
        Retry      = local.lambda_retry
        Next       = "CheckPluginUtilization"
      }
      CheckPluginUtilization = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.plugin_count"
          NumericGreaterThan = 0
          Next               = "WritePluginUtilization"
        }]
        Default = "CheckAgentHours"
      }
      WritePluginUtilization = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.plugin_temp_key"
          "source_key.$"  = "$.source_key"
          "output_prefix" = "enriched_plugins/"
        }
        ResultPath = "$.plugin_write_result"
        Retry      = local.lambda_retry
        Next       = "CheckAgentHours"
      }
      CheckAgentHours = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.agent_hours_count"
          NumericGreaterThan = 0
          Next               = "WriteAgentHoursResults"
        }]
        Default = "CheckFeedback"
      }
      WriteAgentHoursResults = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.agent_hours_temp_key"
          "source_key.$"  = "$.source_key"
          "output_prefix" = "enriched_agent_hours/"
        }
        ResultPath = "$.agent_hours_write_result"
        Retry      = local.lambda_retry
        Next       = "CheckFeedback"
      }
      CheckFeedback = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.feedback_count"
          NumericGreaterThan = 0
          Next               = "WriteFeedbackResults"
        }]
        Default = "Done"
      }
      WriteFeedbackResults = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.feedback_temp_key"
          "source_key.$"  = "$.source_key"
          "output_prefix" = "enriched_feedback/"
        }
        ResultPath = "$.feedback_write_result"
        Retry      = local.lambda_retry
        Next       = "Done"
      }
      Done = {
        Type = "Succeed"
      }
    }
  }) : jsonencode({
    Comment = "Process QuickSuite logs — parse, categorize, write Parquet"
    StartAt = "ParseLogFile"
    States = {
      ParseLogFile = {
        Type     = "Task"
        Resource = aws_lambda_function.parser.arn
        Retry    = local.lambda_retry
        Next     = "CheckChatMessages"
      }
      CheckChatMessages = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.chat_count"
          NumericGreaterThan = 0
          Next               = "CategorizeMessages"
        }]
        Default = "CheckResourceSelections"
      }
      CategorizeMessages = {
        Type     = "Task"
        Resource = aws_lambda_function.categorizer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.chat_temp_key"
          "source_key.$"  = "$.source_key"
        }
        ResultPath = "$.categorize_result"
        Retry      = local.lambda_retry
        Next       = "WriteChatResults"
      }
      WriteChatResults = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$"     = "$.categorize_result.temp_bucket"
          "temp_key.$"        = "$.categorize_result.temp_key"
          "source_key.$"      = "$.source_key"
          "parser_temp_key.$" = "$.chat_temp_key"
          "output_prefix"     = "enriched/"
        }
        ResultPath = "$.chat_write_result"
        Retry      = local.lambda_retry
        Next       = "CheckResourceSelections"
      }
      CheckResourceSelections = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.resource_selections_count"
          NumericGreaterThan = 0
          Next               = "WriteResourceSelections"
        }]
        Default = "CheckPluginUtilization"
      }
      WriteResourceSelections = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.resource_selections_temp_key"
          "source_key.$"  = "$.source_key"
          "output_prefix" = "enriched_resource_selections/"
        }
        ResultPath = "$.resource_selections_write_result"
        Retry      = local.lambda_retry
        Next       = "CheckPluginUtilization"
      }
      CheckPluginUtilization = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.plugin_count"
          NumericGreaterThan = 0
          Next               = "WritePluginUtilization"
        }]
        Default = "CheckAgentHours"
      }
      WritePluginUtilization = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.plugin_temp_key"
          "source_key.$"  = "$.source_key"
          "output_prefix" = "enriched_plugins/"
        }
        ResultPath = "$.plugin_write_result"
        Retry      = local.lambda_retry
        Next       = "CheckAgentHours"
      }
      CheckAgentHours = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.agent_hours_count"
          NumericGreaterThan = 0
          Next               = "WriteAgentHoursResults"
        }]
        Default = "CheckFeedback"
      }
      WriteAgentHoursResults = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.agent_hours_temp_key"
          "source_key.$"  = "$.source_key"
          "output_prefix" = "enriched_agent_hours/"
        }
        ResultPath = "$.agent_hours_write_result"
        Retry      = local.lambda_retry
        Next       = "CheckFeedback"
      }
      CheckFeedback = {
        Type = "Choice"
        Choices = [{
          Variable           = "$.feedback_count"
          NumericGreaterThan = 0
          Next               = "WriteFeedbackResults"
        }]
        Default = "Done"
      }
      WriteFeedbackResults = {
        Type     = "Task"
        Resource = aws_lambda_function.writer.arn
        Parameters = {
          "temp_bucket.$" = "$.temp_bucket"
          "temp_key.$"    = "$.feedback_temp_key"
          "source_key.$"  = "$.source_key"
          "output_prefix" = "enriched_feedback/"
        }
        ResultPath = "$.feedback_write_result"
        Retry      = local.lambda_retry
        Next       = "Done"
      }
      Done = {
        Type = "Succeed"
      }
    }
  })
}
