resource "aws_quicksight_data_set" "resource_selections" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-resource-selections"
  name           = "QuickSuite Resource Selections"
  import_mode    = var.spice_enabled ? "SPICE" : "DIRECT_QUERY"

  physical_table_map {
    physical_table_map_id = "resource-selections-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "resource_selections"
      sql_query       = <<-EOT
        SELECT r.event_timestamp,
               r.conversation_id,
               r.user_arn,
               r.resource_id,
               r.resource_type,
               regexp_extract(r.user_arn, '[^/]+$') AS username,
               r.year,
               r.month,
               r.day
        FROM ${aws_glue_catalog_database.quicksuite.name}.${aws_glue_catalog_table.resource_selections.name} r
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
        name = "resource_id"
        type = "STRING"
      }
      columns {
        name = "resource_type"
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
    logical_table_map_id = "resource-selections-logical"
    alias                = "QuickSuite Resource Selections"
    source {
      physical_table_id = "resource-selections-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "event_timestamp"
        new_column_name = "Timestamp"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "conversation_id"
        new_column_name = "Conversation"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "user_arn"
        new_column_name = "User"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "resource_id"
        new_column_name = "Resource ID"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "resource_type"
        new_column_name = "Resource Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "username"
        new_column_name = "Username"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "year"
        new_column_name = "Year"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "month"
        new_column_name = "Month"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "day"
        new_column_name = "Day"
      }
    }
    data_transforms {
      cast_column_type_operation {
        column_name     = "Timestamp"
        new_column_type = "DATETIME"
        format          = "EPOCH_MILLIS"
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

# SPICE Incremental Refresh Schedule — Resource Selections
resource "aws_quicksight_refresh_schedule" "resource_selections_incremental" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.resource_selections.data_set_id
  schedule_id    = "resource-selections-incremental-refresh"
  schedule {
    refresh_type = "INCREMENTAL_REFRESH"
    schedule_frequency {
      interval = var.spice_refresh_interval
    }
  }
}

# SPICE Full Refresh Schedule — Resource Selections (weekly Sunday 2am UTC)
resource "aws_quicksight_refresh_schedule" "resource_selections_full" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.resource_selections.data_set_id
  schedule_id    = "resource-selections-full-refresh"
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
