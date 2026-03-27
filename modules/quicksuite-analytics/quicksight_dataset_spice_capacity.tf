resource "aws_quicksight_data_set" "spice_capacity" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-spice-capacity"
  name           = "SPICE Capacity"
  import_mode    = "SPICE"

  physical_table_map {
    physical_table_map_id = "spice-capacity-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "spice_capacity"
      sql_query       = <<-EOT
        SELECT timestamp, spice_limit_mb, spice_consumed_mb, year, month, day
        FROM ${aws_glue_catalog_database.quicksuite.name}.qs_spice_capacity
      EOT
      columns {
        name = "timestamp"
        type = "INTEGER"
      }
      columns {
        name = "spice_limit_mb"
        type = "DECIMAL"
      }
      columns {
        name = "spice_consumed_mb"
        type = "DECIMAL"
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
    logical_table_map_id = "spice-capacity-logical"
    alias                = "SPICE Capacity"
    source {
      physical_table_id = "spice-capacity-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "timestamp"
        new_column_name = "Timestamp"
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
      rename_column_operation {
        column_name     = "spice_limit_mb"
        new_column_name = "SPICE Limit (MB)"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "spice_consumed_mb"
        new_column_name = "SPICE Consumed (MB)"
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
  }

  refresh_properties {
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

# SPICE Full Refresh Schedule — SPICE Capacity (daily 3am UTC)
resource "aws_quicksight_refresh_schedule" "spice_capacity_full" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.spice_capacity[0].data_set_id
  schedule_id    = "spice-capacity-full-refresh"
  schedule {
    refresh_type = "FULL_REFRESH"
    schedule_frequency {
      interval        = "DAILY"
      time_of_the_day = "03:00"
      timezone        = "UTC"
    }
  }
}
