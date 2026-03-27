resource "aws_quicksight_data_set" "plugin_utilization" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-plugin-utilization"
  name           = "QuickSuite Plugin Utilization"
  import_mode    = var.spice_enabled ? "SPICE" : "DIRECT_QUERY"

  physical_table_map {
    physical_table_map_id = "plugin-utilization-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "plugin_utilization"
      sql_query       = <<-EOT
        SELECT p.event_timestamp,
               p.conversation_id,
               p.user_arn,
               p.plugin_id,
               regexp_extract(p.user_arn, '[^/]+$') AS username,
               p.year,
               p.month,
               p.day
        FROM ${aws_glue_catalog_database.quicksuite.name}.${aws_glue_catalog_table.plugin_utilization.name} p
      EOT
      columns {
        name = "event_timestamp"
        type = "INTEGER"
      }
      columns {
        name = "conversation_id"
        type = "STRING"
      }
      columns {
        name = "user_arn"
        type = "STRING"
      }
      columns {
        name = "plugin_id"
        type = "STRING"
      }
      columns {
        name = "username"
        type = "STRING"
      }
      columns {
        name = "year"
        type = "STRING"
      }
      columns {
        name = "month"
        type = "STRING"
      }
      columns {
        name = "day"
        type = "STRING"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "plugin-utilization-logical"
    alias                = "QuickSuite Plugin Utilization"
    source {
      physical_table_id = "plugin-utilization-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "event_timestamp"
        new_column_name = "Timestamp"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "plugin_id"
        new_column_name = "Plugin"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "username"
        new_column_name = "Username"
      }
    }
    data_transforms {
      cast_column_type_operation {
        column_name     = "Timestamp"
        new_column_type = "DATETIME"
        format          = "EPOCH_MILLIS"
      }
    }
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "plugin_count"
          column_name = "Plugin Count"
          expression  = "1"
        }
      }
    }
  }

  dynamic "refresh_properties" {
    for_each = var.spice_enabled ? [1] : []
    content {
      refresh_configuration {
        incremental_refresh {
          lookback_window {
            column_name = "Timestamp"
            size        = 7
            size_unit   = "DAY"
          }
        }
      }
    }
  }

  permissions {
    actions = [
      "quicksight:DescribeDataSet",
      "quicksight:DescribeDataSetPermissions",
      "quicksight:PassDataSet",
      "quicksight:DescribeIngestion",
      "quicksight:ListIngestions",
      "quicksight:UpdateDataSet",
      "quicksight:DeleteDataSet",
      "quicksight:CreateIngestion",
      "quicksight:CancelIngestion",
      "quicksight:UpdateDataSetPermissions",
    ]
    principal = "arn:aws:quicksight:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:group/${var.quicksight_namespace}/${var.quicksight_admin_group}"
  }
}

# SPICE Incremental Refresh Schedule — Plugin Utilization
resource "aws_quicksight_refresh_schedule" "plugin_utilization_incremental" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.plugin_utilization.data_set_id
  schedule_id    = "plugin-utilization-incremental-refresh"
  schedule {
    refresh_type = "INCREMENTAL_REFRESH"
    schedule_frequency {
      interval = var.spice_refresh_interval
    }
  }
}

# SPICE Full Refresh Schedule — Plugin Utilization (weekly Sunday 2am UTC)
resource "aws_quicksight_refresh_schedule" "plugin_utilization_full" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.plugin_utilization.data_set_id
  schedule_id    = "plugin-utilization-full-refresh"
  schedule {
    refresh_type = "FULL_REFRESH"
    schedule_frequency {
      interval = "WEEKLY"
      refresh_on_day { day_of_week = "SUNDAY" }
      time_of_the_day = "02:00"
      timezone        = "UTC"
    }
  }
}
