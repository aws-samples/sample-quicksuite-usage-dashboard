resource "aws_quicksight_data_set" "bi_assets" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-bi-assets"
  name           = "QuickSight BI Assets"
  import_mode    = var.spice_enabled ? "SPICE" : "DIRECT_QUERY"

  physical_table_map {
    physical_table_map_id = "bi-assets-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "bi_assets"
      sql_query       = <<-EOT
        SELECT 'Dashboard' AS asset_type, dashboard_name AS name, dashboard_id AS id,
               dataset_name, dataset_id, NULL AS status, NULL AS datasource_type, synced_at
        FROM ${aws_glue_catalog_database.quicksuite.name}.qs_dashboards
        UNION ALL
        SELECT 'Analysis', analysis_name, analysis_id,
               dataset_name, dataset_id, status, NULL, synced_at
        FROM ${aws_glue_catalog_database.quicksuite.name}.qs_analyses
        UNION ALL
        SELECT 'Datasource', datasource_name, datasource_id,
               dataset_name, dataset_id, NULL, datasource_type, synced_at
        FROM ${aws_glue_catalog_database.quicksuite.name}.qs_datasources
      EOT
      columns {
        name = "asset_type"
        type = "STRING"
      }
      columns {
        name = "name"
        type = "STRING"
      }
      columns {
        name = "id"
        type = "STRING"
      }
      columns {
        name = "dataset_name"
        type = "STRING"
      }
      columns {
        name = "dataset_id"
        type = "STRING"
      }
      columns {
        name = "status"
        type = "STRING"
      }
      columns {
        name = "datasource_type"
        type = "STRING"
      }
      columns {
        name = "synced_at"
        type = "STRING"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "bi-assets-logical"
    alias                = "QuickSight BI Assets"
    source {
      physical_table_id = "bi-assets-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "asset_type"
        new_column_name = "Asset Type"
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
        column_name     = "id"
        new_column_name = "ID"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "dataset_name"
        new_column_name = "Dataset Name"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "dataset_id"
        new_column_name = "Dataset ID"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "status"
        new_column_name = "Status"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "datasource_type"
        new_column_name = "Datasource Type"
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

# SPICE Full Refresh Schedule — BI Assets (daily 3am UTC)
resource "aws_quicksight_refresh_schedule" "bi_assets_full" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.bi_assets.data_set_id
  schedule_id    = "bi-assets-full-refresh"
  schedule {
    refresh_type = "FULL_REFRESH"
    schedule_frequency {
      interval        = "DAILY"
      time_of_the_day = "03:00"
      timezone        = "UTC"
    }
  }
}
