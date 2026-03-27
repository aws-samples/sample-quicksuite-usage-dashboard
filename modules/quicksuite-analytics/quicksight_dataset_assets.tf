resource "aws_quicksight_data_set" "asset_inventory" {
  count          = local.cloudtrail_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = "quicksuite-asset-inventory"
  name           = "QuickSuite Asset Inventory"
  import_mode    = var.spice_enabled ? "SPICE" : "DIRECT_QUERY"

  physical_table_map {
    physical_table_map_id = "asset-inventory-sql"
    custom_sql {
      data_source_arn = aws_quicksight_data_source.athena.arn
      name            = "asset_inventory"
      sql_query       = <<-EOT
        SELECT
          eventtime,
          eventname,
          eventsource,
          useridentity.onbehalfof.userid AS idc_user_id,
          CASE
            WHEN eventname LIKE 'Create%Space%' THEN 'Space'
            WHEN eventname LIKE '%KnowledgeBase%' THEN 'Knowledge Base'
            WHEN eventname LIKE '%Flow%' THEN 'Flow'
            WHEN eventname LIKE '%Agent%' THEN 'Agent'
            WHEN eventname LIKE '%Document%' THEN 'Document'
            WHEN eventname LIKE '%Automation%' THEN 'Automation'
            WHEN eventname = 'UploadAttachment' THEN 'Upload'
            WHEN eventname LIKE '%ActionConnector%' THEN 'Action Connector'
            ELSE 'Other'
          END AS asset_type,
          CASE
            WHEN eventname LIKE 'Create%' THEN 'Create'
            WHEN eventname LIKE 'Update%' THEN 'Update'
            WHEN eventname LIKE 'Delete%' THEN 'Delete'
            WHEN eventname LIKE 'Upload%' THEN 'Upload'
            WHEN eventname LIKE 'Patch%' THEN 'Update'
            ELSE 'Other'
          END AS operation,
          json_extract_scalar(serviceeventdetails, '$.eventRequestDetails.attachmentName') AS attachment_name,
          COALESCE(
            CAST(json_extract_scalar(serviceeventdetails, '$.eventRequestDetails.contentLength') AS BIGINT),
            CAST(json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.response.size') AS BIGINT)
          ) AS content_length_bytes,
          COALESCE(
            json_extract_scalar(serviceeventdetails, '$.eventRequestDetails.contentType'),
            json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.response.contentType')
          ) AS content_type,
          COALESCE(
            json_extract_scalar(serviceeventdetails, '$.eventRequestDetails.spaceId'),
            json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.spaceId'),
            json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.response.spaceId')
          ) AS space_id,
          json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.spaceArn') AS space_arn,
          json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.knowledgeBaseId') AS knowledge_base_id,
          COALESCE(
            json_extract_scalar(serviceeventdetails, '$.eventRequestDetails.name'),
            json_extract_scalar(serviceeventdetails, '$.eventRequestDetails.documentName'),
            json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.response.name')
          ) AS asset_name,
          json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.knowledgeBaseType') AS knowledge_base_type,
          COALESCE(
            json_extract_scalar(serviceeventdetails, '$.eventResponseDetails.response.addedBy'),
            useridentity.onbehalfof.userid
          ) AS added_by,
          year, month, day
        FROM ${aws_glue_catalog_database.quicksuite.name}.${aws_glue_catalog_table.cloudtrail[0].name}
        WHERE eventsource = 'quicksight.amazonaws.com'
          AND readonly = false
          AND eventname IN (
            'CreateSpace', 'CreateInlineSpace', 'UpdateSpace',
            'CreateKnowledgeBase', 'CreateKnowledgeBaseIngestion', 'UpdateKnowledgeBase',
            'CreateFlow', 'UpdateFlow',
            'CreateAgent', 'CreateAgentFromPrompt', 'UpdateAgent', 'UpdateAgentAssociations',
            'CreateDocument',
            'CreateAutomation', 'CreateAutomationGroup', 'CreateAutomationGroupAssociation',
            'UpdateAutomationGroupPermissions',
            'CreateActionConnector', 'PatchActionConnector',
            'UploadAttachment',
            'CreateWorkflowVersion', 'UpdateWorkflow'
          )
      EOT
      columns {
        name = "eventtime"
        type = "STRING"
      }
      columns {
        name = "eventname"
        type = "STRING"
      }
      columns {
        name = "eventsource"
        type = "STRING"
      }
      columns {
        name = "idc_user_id"
        type = "STRING"
      }
      columns {
        name = "asset_type"
        type = "STRING"
      }
      columns {
        name = "operation"
        type = "STRING"
      }
      columns {
        name = "attachment_name"
        type = "STRING"
      }
      columns {
        name = "content_length_bytes"
        type = "INTEGER"
      }
      columns {
        name = "content_type"
        type = "STRING"
      }
      columns {
        name = "space_id"
        type = "STRING"
      }
      columns {
        name = "space_arn"
        type = "STRING"
      }
      columns {
        name = "knowledge_base_id"
        type = "STRING"
      }
      columns {
        name = "asset_name"
        type = "STRING"
      }
      columns {
        name = "knowledge_base_type"
        type = "STRING"
      }
      columns {
        name = "added_by"
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
    logical_table_map_id = "asset-inventory-logical"
    alias                = "QuickSuite Asset Inventory"
    source {
      physical_table_id = "asset-inventory-sql"
    }
    data_transforms {
      rename_column_operation {
        column_name     = "eventtime"
        new_column_name = "Timestamp"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "eventname"
        new_column_name = "Event Name"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "idc_user_id"
        new_column_name = "User ID"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "asset_type"
        new_column_name = "Asset Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "operation"
        new_column_name = "Operation"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "attachment_name"
        new_column_name = "File Name"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "content_length_bytes"
        new_column_name = "File Size (Bytes)"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "content_type"
        new_column_name = "Content Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "asset_name"
        new_column_name = "Asset Name"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "knowledge_base_type"
        new_column_name = "KB Type"
      }
    }
    data_transforms {
      rename_column_operation {
        column_name     = "added_by"
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
        format          = "yyyy-MM-dd'T'HH:mm:ss'Z'"
      }
    }
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "file_size_mb"
          column_name = "File Size (MB)"
          expression  = "{File Size (Bytes)} / 1024.0 / 1024.0"
        }
      }
    }
    data_transforms {
      create_columns_operation {
        columns {
          column_id   = "event_count"
          column_name = "Event Count"
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

# SPICE Incremental Refresh Schedule — Asset Inventory
resource "aws_quicksight_refresh_schedule" "asset_inventory_incremental" {
  count          = local.cloudtrail_enabled && var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.asset_inventory[0].data_set_id
  schedule_id    = "asset-inventory-incremental-refresh"
  schedule {
    refresh_type = "INCREMENTAL_REFRESH"
    schedule_frequency {
      interval = var.spice_refresh_interval
    }
  }
}

# SPICE Full Refresh Schedule — Asset Inventory (weekly Sunday 2am UTC)
resource "aws_quicksight_refresh_schedule" "asset_inventory_full" {
  count          = local.cloudtrail_enabled && var.spice_enabled ? 1 : 0
  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.asset_inventory[0].data_set_id
  schedule_id    = "asset-inventory-full-refresh"
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
