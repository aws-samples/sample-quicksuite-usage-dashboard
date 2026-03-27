resource "aws_quicksight_data_set" "messages" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-messages"
  name           = "QuickSuite Messages"
  import_mode    = var.spice_enabled ? "SPICE" : "DIRECT_QUERY"

  physical_table_map {
    physical_table_map_id = "chat-logs-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "chat_logs"
      sql_query       = <<-EOT
        SELECT m.event_timestamp,
               'CHAT_LOGS' AS log_type,
               m.user_arn,
               m.user_type,
               m.status_code,
               m.conversation_id,
               m.agent_id,
               m.flow_id,
               NULL AS subscription_type,
               NULL AS reporting_service,
               NULL AS usage_group,
               CAST(NULL AS DOUBLE) AS usage_hours,
               NULL AS service_resource_arn,
               regexp_extract(m.user_arn, '[^/]+$') AS username,
               m.year,
               m.month,
               m.day,
               u.display_name,
               u.email,
               u.title,
               u.department,
               u.country,
               u.manager,
               u.license_type,
               u.monthly_agent_hours_allotment,
               m.query_scope,
               m.message_scope,
               m.prompt_category,
               m.action_intent,
               m.contains_customer_info,
               NULL AS feedback_type,
               NULL AS feedback_reason,
               NULL AS rating,
               u.user_tier
        FROM ${aws_glue_catalog_database.quicksuite.name}.message_enriched m
        LEFT JOIN ${aws_glue_catalog_database.quicksuite.name}.user_attributes u
          ON regexp_extract(m.user_arn, '[^/]+$') = u.username

        UNION ALL

        SELECT a.event_timestamp,
               'AGENT_HOURS_LOGS' AS log_type,
               a.user_arn,
               NULL AS user_type,
               NULL AS status_code,
               NULL AS conversation_id,
               NULL AS agent_id,
               NULL AS flow_id,
               a.subscription_type,
               a.reporting_service,
               a.usage_group,
               a.usage_hours,
               a.service_resource_arn,
               regexp_extract(a.user_arn, '[^/]+$') AS username,
               a.year,
               a.month,
               a.day,
               u.display_name,
               u.email,
               u.title,
               u.department,
               u.country,
               u.manager,
               u.license_type,
               u.monthly_agent_hours_allotment,
               NULL AS query_scope,
               NULL AS message_scope,
               NULL AS prompt_category,
               NULL AS action_intent,
               NULL AS contains_customer_info,
               NULL AS feedback_type,
               NULL AS feedback_reason,
               NULL AS rating,
               u.user_tier
        FROM ${aws_glue_catalog_database.quicksuite.name}.agent_hours_enriched a
        LEFT JOIN ${aws_glue_catalog_database.quicksuite.name}.user_attributes u
          ON regexp_extract(a.user_arn, '[^/]+$') = u.username

        UNION ALL

        SELECT f.event_timestamp,
               'FEEDBACK_LOGS' AS log_type,
               f.user_arn,
               NULL AS user_type,
               NULL AS status_code,
               f.conversation_id,
               NULL AS agent_id,
               NULL AS flow_id,
               NULL AS subscription_type,
               NULL AS reporting_service,
               NULL AS usage_group,
               CAST(NULL AS DOUBLE) AS usage_hours,
               NULL AS service_resource_arn,
               regexp_extract(f.user_arn, '[^/]+$') AS username,
               f.year,
               f.month,
               f.day,
               u.display_name,
               u.email,
               u.title,
               u.department,
               u.country,
               u.manager,
               u.license_type,
               u.monthly_agent_hours_allotment,
               NULL AS query_scope,
               NULL AS message_scope,
               c.prompt_category,
               c.action_intent,
               c.contains_customer_info,
               f.feedback_type,
               f.feedback_reason,
               f.rating,
               u.user_tier
        FROM ${aws_glue_catalog_database.quicksuite.name}.${aws_glue_catalog_table.feedback_enriched.name} f
        LEFT JOIN ${aws_glue_catalog_database.quicksuite.name}.user_attributes u
          ON regexp_extract(f.user_arn, '[^/]+$') = u.username
        LEFT JOIN ${aws_glue_catalog_database.quicksuite.name}.message_enriched c
          ON f.conversation_id = c.conversation_id
          AND f.system_message_id = c.system_message_id
      EOT
      columns {
        name = "event_timestamp"
        type = "INTEGER"
      }
      columns {
        name = "log_type"
        type = "STRING"
      }
      columns {
        name = "user_arn"
        type = "STRING"
      }
      columns {
        name = "user_type"
        type = "STRING"
      }
      columns {
        name = "status_code"
        type = "STRING"
      }
      columns {
        name = "conversation_id"
        type = "STRING"
      }
      columns {
        name = "agent_id"
        type = "STRING"
      }
      columns {
        name = "flow_id"
        type = "STRING"
      }
      columns {
        name = "subscription_type"
        type = "STRING"
      }
      columns {
        name = "reporting_service"
        type = "STRING"
      }
      columns {
        name = "usage_group"
        type = "STRING"
      }
      columns {
        name = "usage_hours"
        type = "DECIMAL"
      }
      columns {
        name = "service_resource_arn"
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
        name = "manager"
        type = "STRING"
      }
      columns {
        name = "license_type"
        type = "STRING"
      }
      columns {
        name = "monthly_agent_hours_allotment"
        type = "DECIMAL"
      }
      columns {
        name = "query_scope"
        type = "STRING"
      }
      columns {
        name = "message_scope"
        type = "STRING"
      }
      columns {
        name = "feedback_type"
        type = "STRING"
      }
      columns {
        name = "feedback_reason"
        type = "STRING"
      }
      columns {
        name = "rating"
        type = "STRING"
      }
      columns {
        name = "user_tier"
        type = "STRING"
      }
      columns {
        name = "prompt_category"
        type = "STRING"
      }
      columns {
        name = "action_intent"
        type = "STRING"
      }
      columns {
        name = "contains_customer_info"
        type = "STRING"
      }
    }
  }

  logical_table_map {
    logical_table_map_id = "chat-logs-logical"
    alias                = "QuickSuite Messages"
    source {
      physical_table_id = "chat-logs-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "event_timestamp"
        new_column_name = "Timestamp"
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
        column_name     = "conversation_id"
        new_column_name = "Conversation"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "status_code"
        new_column_name = "Status"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "user_type"
        new_column_name = "User Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "agent_id"
        new_column_name = "Agent ID"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "flow_id"
        new_column_name = "Flow ID"
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
      rename_column_operation {
        column_name     = "log_type"
        new_column_name = "Log Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "subscription_type"
        new_column_name = "Subscription Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "reporting_service"
        new_column_name = "Reporting Service"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "usage_group"
        new_column_name = "Usage Group"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "usage_hours"
        new_column_name = "Usage Hours"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "service_resource_arn"
        new_column_name = "Service Resource ARN"
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
        column_name     = "manager"
        new_column_name = "Manager"
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
        column_name     = "monthly_agent_hours_allotment"
        new_column_name = "Monthly Allotment"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "query_scope"
        new_column_name = "Query Scope"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "message_scope"
        new_column_name = "Message Scope"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "feedback_type"
        new_column_name = "Feedback Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "feedback_reason"
        new_column_name = "Feedback Reason"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "rating"
        new_column_name = "Rating"
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
        column_name     = "prompt_category"
        new_column_name = "Prompt Category"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "action_intent"
        new_column_name = "Action Intent"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "contains_customer_info"
        new_column_name = "Contains Customer Info"
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
          column_id   = "message_count"
          column_name = "Message Count"
          expression  = "1"
        }
      }
    }
    # Per-user % of agent hours allotment consumed (for distribution chart)
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "pct_consumed"
          column_name = "Pct Consumed"
          expression  = "ifelse({Monthly Allotment} > 0, sumOver({Usage Hours}, [{Username}], PRE_AGG) / maxOver({Monthly Allotment}, [{Username}], PRE_AGG), NULL)"
        }
      }
    }
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "allotment_bucket"
          column_name = "Allotment Bucket"
          expression  = "ifelse({Pct Consumed} >= 1.0, '>100%', ifelse({Pct Consumed} >= 0.75, '75-99%', ifelse({Pct Consumed} >= 0.5, '50-74%', ifelse({Pct Consumed} >= 0.25, '25-49%', '<25%'))))"
        }
      }
    }
    # Avg queries per user (for KPI)
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "avg_queries_per_user"
          column_name = "Avg Queries Per User"
          expression  = "sumOver({Message Count}, [], PRE_AGG) / distinctCountOver({Username}, [], PRE_AGG)"
        }
      }
    }
    # Avg queries per conversation (for KPI)
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "avg_queries_per_conversation"
          column_name = "Avg Queries Per Conversation"
          expression  = "sumOver({Message Count}, [], PRE_AGG) / distinctCountOver({Conversation}, [], PRE_AGG)"
        }
      }
    }
    # Agent Label — replace SYSTEM with human-readable label
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "agent_label"
          column_name = "Agent Label"
          expression  = "ifelse({Agent ID}='SYSTEM', 'Default Assistant', {Agent ID})"
        }
      }
    }
    # Hour of Day (0-23)
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "hour_of_day"
          column_name = "Hour of Day"
          expression  = "extract('HH', {Timestamp})"
        }
      }
    }
    # Day of Week (1=Sun ... 7=Sat)
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "day_of_week"
          column_name = "Day of Week"
          expression  = "extract('WD', {Timestamp})"
        }
      }
    }
    # Day of Week Label
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "day_of_week_label"
          column_name = "Day of Week Label"
          expression  = "ifelse(extract('WD',{Timestamp})=1,'Sun',ifelse(extract('WD',{Timestamp})=2,'Mon',ifelse(extract('WD',{Timestamp})=3,'Tue',ifelse(extract('WD',{Timestamp})=4,'Wed',ifelse(extract('WD',{Timestamp})=5,'Thu',ifelse(extract('WD',{Timestamp})=6,'Fri','Sat'))))))"
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

# SPICE Incremental Refresh Schedule
resource "aws_quicksight_refresh_schedule" "incremental" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.messages.data_set_id
  schedule_id    = "incremental-refresh"
  schedule {
    refresh_type = "INCREMENTAL_REFRESH"
    schedule_frequency {
      interval = var.spice_refresh_interval
    }
  }
}

# SPICE Full Refresh Schedule (hardcoded: weekly Sunday 2am UTC)
resource "aws_quicksight_refresh_schedule" "full" {
  count          = var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.messages.data_set_id
  schedule_id    = "full-refresh"
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
