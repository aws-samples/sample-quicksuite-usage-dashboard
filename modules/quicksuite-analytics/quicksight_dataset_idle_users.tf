resource "aws_quicksight_data_set" "idle_users" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-idle-users"
  name           = "QuickSuite Idle Users"
  import_mode    = "DIRECT_QUERY"

  physical_table_map {
    physical_table_map_id = "idle-users-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "idle_users"
      sql_query       = <<-EOT
        SELECT u.display_name,
               u.email,
               u.username,
               u.department,
               u.title,
               u.user_tier
        FROM ${aws_glue_catalog_database.quicksuite.name}.user_attributes u
        WHERE u.username NOT IN (
          SELECT DISTINCT regexp_extract(m.user_arn, '[^/]+$')
          FROM ${aws_glue_catalog_database.quicksuite.name}.message_enriched m
          WHERE from_unixtime(m.event_timestamp / 1000) >= date_add('day', -90, current_date)
        )
      EOT
      columns {
        name = "display_name"
        type = "STRING"
      }
      columns {
        name = "email"
        type = "STRING"
      }
      columns {
        name = "username"
        type = "STRING"
      }
      columns {
        name = "department"
        type = "STRING"
      }
      columns {
        name = "title"
        type = "STRING"
      }
      columns {
        name = "user_tier"
        type = "STRING"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "idle-users-logical"
    alias                = "Idle Users"
    source {
      physical_table_id = "idle-users-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "display_name"
        new_column_name = "Name"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "email"
        new_column_name = "Email"
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
        column_name     = "department"
        new_column_name = "Department"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "title"
        new_column_name = "Job Title"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "user_tier"
        new_column_name = "User Tier"
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
