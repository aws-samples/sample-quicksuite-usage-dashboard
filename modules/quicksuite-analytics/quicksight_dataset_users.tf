resource "aws_quicksight_data_set" "users" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-users"
  name           = "QuickSuite Users"
  import_mode    = var.spice_enabled ? "SPICE" : "DIRECT_QUERY"

  physical_table_map {
    physical_table_map_id = "users-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "all_users"
      sql_query       = <<-EOT
        SELECT u.user_id,
               u.username,
               u.display_name,
               u.email,
               u.title,
               u.department,
               u.country,
               u.employee_number,
               u.quicksight_role,
               u.license_type,
               u.user_tier,
               CAST(u.monthly_agent_hours_allotment AS VARCHAR) AS monthly_agent_hours_allotment
        FROM ${aws_glue_catalog_database.quicksuite.name}.user_attributes u
      EOT
      columns {
        name = "user_id"
        type = "STRING"
      }
      columns {
        name = "username"
        type = "STRING"
      }
      columns {
        name = "display_name"
        type = "STRING"
      }
      columns {
        name = "email"
        type = "STRING"
      }
      columns {
        name = "title"
        type = "STRING"
      }
      columns {
        name = "department"
        type = "STRING"
      }
      columns {
        name = "country"
        type = "STRING"
      }
      columns {
        name = "employee_number"
        type = "STRING"
      }
      columns {
        name = "quicksight_role"
        type = "STRING"
      }
      columns {
        name = "license_type"
        type = "STRING"
      }
      columns {
        name = "user_tier"
        type = "STRING"
      }
      columns {
        name = "monthly_agent_hours_allotment"
        type = "STRING"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "users-logical"
    alias                = "All Users"
    source {
      physical_table_id = "users-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "user_id"
        new_column_name = "User ID"
      }
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
        column_name     = "title"
        new_column_name = "Job Title"
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
        column_name     = "country"
        new_column_name = "Country"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "employee_number"
        new_column_name = "Employee Number"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "quicksight_role"
        new_column_name = "QuickSight Role"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "license_type"
        new_column_name = "License Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "user_tier"
        new_column_name = "User Tier"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "monthly_agent_hours_allotment"
        new_column_name = "Agent Hours Allotment"
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
