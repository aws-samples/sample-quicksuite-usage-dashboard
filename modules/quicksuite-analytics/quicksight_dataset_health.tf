resource "aws_quicksight_data_set" "dataset_health" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-dataset-health"
  name           = "Dataset Health"
  import_mode    = var.spice_enabled ? "SPICE" : "DIRECT_QUERY"

  physical_table_map {
    physical_table_map_id = "dataset-health-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "dataset_health"
      sql_query       = <<-EOT
        SELECT dataset_id, name, import_mode, last_updated_time, consumed_spice_bytes,
               rows_ingested, rows_dropped, ingestion_status, refresh_triggered_time,
               refresh_time_seconds, request_source, request_type, error_type, error_message,
               permission_count, is_orphaned, synced_at
        FROM ${aws_glue_catalog_database.quicksuite.name}.qs_datasets
      EOT
      columns {
        name = "dataset_id"
        type = "STRING"
      }
      columns {
        name = "name"
        type = "STRING"
      }
      columns {
        name = "import_mode"
        type = "STRING"
      }
      columns {
        name = "last_updated_time"
        type = "STRING"
      }
      columns {
        name = "consumed_spice_bytes"
        type = "INTEGER"
      }
      columns {
        name = "rows_ingested"
        type = "INTEGER"
      }
      columns {
        name = "rows_dropped"
        type = "INTEGER"
      }
      columns {
        name = "ingestion_status"
        type = "STRING"
      }
      columns {
        name = "refresh_triggered_time"
        type = "STRING"
      }
      columns {
        name = "refresh_time_seconds"
        type = "DECIMAL"
      }
      columns {
        name = "request_source"
        type = "STRING"
      }
      columns {
        name = "request_type"
        type = "STRING"
      }
      columns {
        name = "error_type"
        type = "STRING"
      }
      columns {
        name = "error_message"
        type = "STRING"
      }
      columns {
        name = "permission_count"
        type = "INTEGER"
      }
      columns {
        name = "is_orphaned"
        type = "STRING"
      }
      columns {
        name = "synced_at"
        type = "STRING"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "dataset-health-logical"
    alias                = "Dataset Health"
    source {
      physical_table_id = "dataset-health-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "dataset_id"
        new_column_name = "Dataset ID"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "name"
        new_column_name = "Name"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "import_mode"
        new_column_name = "Import Mode"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "last_updated_time"
        new_column_name = "Last Updated"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "consumed_spice_bytes"
        new_column_name = "SPICE Bytes"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "rows_ingested"
        new_column_name = "Rows Ingested"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "rows_dropped"
        new_column_name = "Rows Dropped"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "ingestion_status"
        new_column_name = "Ingestion Status"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "refresh_triggered_time"
        new_column_name = "Refresh Triggered At"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "refresh_time_seconds"
        new_column_name = "Refresh Duration (s)"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "request_source"
        new_column_name = "Request Source"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "request_type"
        new_column_name = "Request Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "error_type"
        new_column_name = "Error Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "error_message"
        new_column_name = "Error Message"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "permission_count"
        new_column_name = "Permission Count"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "is_orphaned"
        new_column_name = "Is Orphaned"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "synced_at"
        new_column_name = "Synced At"
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

# SPICE Full Refresh Schedule — Dataset Health (daily 3am UTC)
resource "aws_quicksight_refresh_schedule" "dataset_health_full" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.dataset_health.data_set_id
  schedule_id    = "dataset-health-full-refresh"
  schedule {
    refresh_type = "FULL_REFRESH"
    schedule_frequency {
      interval        = "DAILY"
      time_of_the_day = "03:00"
      timezone        = "UTC"
    }
  }
}
