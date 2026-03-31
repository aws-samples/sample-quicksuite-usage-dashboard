resource "aws_glue_catalog_database" "quicksuite" {
  name = "quicksuite_analytics"
}

# Raw logs table — partition projection on CloudWatch vended log path
resource "aws_glue_catalog_table" "awslogs" {
  name          = "awslogs"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"              = "json"
    "projection.enabled"          = "true"
    "projection.year.type"        = "integer"
    "projection.year.range"       = "2024,2030"
    "projection.year.digits"      = "4"
    "projection.month.type"       = "integer"
    "projection.month.range"      = "1,12"
    "projection.month.digits"     = "2"
    "projection.day.type"         = "integer"
    "projection.day.range"        = "1,31"
    "projection.day.digits"       = "2"
    "projection.hour.type"        = "integer"
    "projection.hour.range"       = "0,23"
    "projection.hour.digits"      = "2"
    "storage.location.template"   = "s3://${aws_s3_bucket.quicksuite_logs.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/quicksuitelogs/${data.aws_region.current.id}/${data.aws_caller_identity.current.account_id}/$${year}/$${month}/$${day}/$${hour}/"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }
  partition_keys {
    name = "hour"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/quicksuitelogs/${data.aws_region.current.id}/${data.aws_caller_identity.current.account_id}/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "event_timestamp"
      type = "bigint"
    }
    columns {
      name = "logtype"
      type = "string"
    }
    columns {
      name = "accountid"
      type = "string"
    }
    columns {
      name = "user_arn"
      type = "string"
    }
    columns {
      name = "user_type"
      type = "string"
    }
    columns {
      name = "status_code"
      type = "string"
    }
    columns {
      name = "conversation_id"
      type = "string"
    }
    columns {
      name = "system_message_id"
      type = "string"
    }
    columns {
      name = "message_scope"
      type = "string"
    }
    columns {
      name = "user_message_id"
      type = "string"
    }
    columns {
      name = "user_message"
      type = "string"
    }
    columns {
      name = "system_text_message"
      type = "string"
    }
    columns {
      name = "agent_id"
      type = "string"
    }
    columns {
      name = "flow_id"
      type = "string"
    }
    columns {
      name = "user_selected_resources"
      type = "array<struct<resourceId:string,resourceType:string>>"
    }
    columns {
      name = "action_connectors"
      type = "array<struct<actionConnectorId:string>>"
    }
    columns {
      name = "cited_resource"
      type = "array<struct<citedResourceType:string,citedResourceId:string,citedResourceName:string>>"
    }
    columns {
      name = "file_attachment"
      type = "array<string>"
    }
    columns {
      name = "research_id"
      type = "string"
    }
    columns {
      name = "feedback_type"
      type = "string"
    }
    columns {
      name = "feedback_reason"
      type = "string"
    }
    columns {
      name = "rating"
      type = "string"
    }
    columns {
      name = "subscription_type"
      type = "string"
    }
    columns {
      name = "reporting_service"
      type = "string"
    }
    columns {
      name = "usage_group"
      type = "string"
    }
    columns {
      name = "usage_hours"
      type = "double"
    }
    columns {
      name = "service_resource_arn"
      type = "string"
    }
    columns {
      name = "resource_arn"
      type = "string"
    }
  }
}

# Enriched agent hours table — partition projection on Hive-style Parquet output
resource "aws_glue_catalog_table" "agent_hours_enriched" {
  name          = "agent_hours_enriched"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"              = "parquet"
    "projection.enabled"          = "true"
    "projection.year.type"        = "integer"
    "projection.year.range"       = "2024,2030"
    "projection.year.digits"      = "4"
    "projection.month.type"       = "integer"
    "projection.month.range"      = "1,12"
    "projection.month.digits"     = "2"
    "projection.day.type"         = "integer"
    "projection.day.range"        = "1,31"
    "projection.day.digits"       = "2"
    "storage.location.template"   = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched_agent_hours/year=$${year}/month=$${month}/day=$${day}/"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched_agent_hours/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "event_timestamp"
      type = "bigint"
    }
    columns {
      name = "user_arn"
      type = "string"
    }
    columns {
      name = "subscription_type"
      type = "string"
    }
    columns {
      name = "reporting_service"
      type = "string"
    }
    columns {
      name = "usage_group"
      type = "string"
    }
    columns {
      name = "usage_hours"
      type = "double"
    }
    columns {
      name = "service_resource_arn"
      type = "string"
    }
  }
}

# User attributes table — JSONL, no partitions, overwritten on each user sync
resource "aws_glue_catalog_table" "user_attributes" {
  name          = "user_attributes"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/user_attributes/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "user_id"
      type = "string"
    }
    columns {
      name = "username"
      type = "string"
    }
    columns {
      name = "display_name"
      type = "string"
    }
    columns {
      name = "email"
      type = "string"
    }
    columns {
      name = "title"
      type = "string"
    }
    columns {
      name = "department"
      type = "string"
    }
    columns {
      name = "division"
      type = "string"
    }
    columns {
      name = "organization"
      type = "string"
    }
    columns {
      name = "cost_center"
      type = "string"
    }
    columns {
      name = "employee_number"
      type = "string"
    }
    columns {
      name = "country"
      type = "string"
    }
    columns {
      name = "manager"
      type = "string"
    }
    columns {
      name = "quicksight_role"
      type = "string"
    }
    columns {
      name = "license_type"
      type = "string"
    }
    columns {
      name = "monthly_agent_hours_allotment"
      type = "double"
    }
    columns {
      name = "synced_at"
      type = "string"
    }
    columns {
      name = "user_tier"
      type = "string"
    }
    columns {
      name = "first_seen_date"
      type = "bigint"
    }
  }
}

# Enriched messages table — partition projection on Hive-style Parquet output
resource "aws_glue_catalog_table" "message_enriched" {
  name          = "message_enriched"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"              = "parquet"
    "projection.enabled"          = "true"
    "projection.year.type"        = "integer"
    "projection.year.range"       = "2024,2030"
    "projection.year.digits"      = "4"
    "projection.month.type"       = "integer"
    "projection.month.range"      = "1,12"
    "projection.month.digits"     = "2"
    "projection.day.type"         = "integer"
    "projection.day.range"        = "1,31"
    "projection.day.digits"       = "2"
    "storage.location.template"   = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched/year=$${year}/month=$${month}/day=$${day}/"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "event_timestamp"
      type = "bigint"
    }
    columns {
      name = "user_arn"
      type = "string"
    }
    columns {
      name = "user_type"
      type = "string"
    }
    columns {
      name = "status_code"
      type = "string"
    }
    columns {
      name = "conversation_id"
      type = "string"
    }
    columns {
      name = "agent_id"
      type = "string"
    }
    columns {
      name = "flow_id"
      type = "string"
    }
    columns {
      name = "query_scope"
      type = "string"
    }
    columns {
      name = "message_scope"
      type = "string"
    }
    columns {
      name = "system_message_id"
      type = "string"
    }
    columns {
      name = "prompt_category"
      type = "string"
    }
    columns {
      name = "action_intent"
      type = "string"
    }
    columns {
      name = "contains_customer_info"
      type = "string"
    }
  }
}

# Enriched feedback table — partition projection on Hive-style Parquet output
resource "aws_glue_catalog_table" "feedback_enriched" {
  name          = "feedback_enriched"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"              = "parquet"
    "projection.enabled"          = "true"
    "projection.year.type"        = "integer"
    "projection.year.range"       = "2024,2030"
    "projection.year.digits"      = "4"
    "projection.month.type"       = "integer"
    "projection.month.range"      = "1,12"
    "projection.month.digits"     = "2"
    "projection.day.type"         = "integer"
    "projection.day.range"        = "1,31"
    "projection.day.digits"       = "2"
    "storage.location.template"   = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched_feedback/year=$${year}/month=$${month}/day=$${day}/"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched_feedback/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "event_timestamp"
      type = "bigint"
    }
    columns {
      name = "user_arn"
      type = "string"
    }
    columns {
      name = "conversation_id"
      type = "string"
    }
    columns {
      name = "feedback_type"
      type = "string"
    }
    columns {
      name = "feedback_reason"
      type = "string"
    }
    columns {
      name = "rating"
      type = "string"
    }
    columns {
      name = "system_message_id"
      type = "string"
    }
  }
}

# Resource selections table — partition projection on Hive-style Parquet output
resource "aws_glue_catalog_table" "resource_selections" {
  name          = "resource_selections"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"              = "parquet"
    "projection.enabled"          = "true"
    "projection.year.type"        = "integer"
    "projection.year.range"       = "2024,2030"
    "projection.year.digits"      = "4"
    "projection.month.type"       = "integer"
    "projection.month.range"      = "1,12"
    "projection.month.digits"     = "2"
    "projection.day.type"         = "integer"
    "projection.day.range"        = "1,31"
    "projection.day.digits"       = "2"
    "storage.location.template"   = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched_resource_selections/year=$${year}/month=$${month}/day=$${day}/"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched_resource_selections/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "event_timestamp"
      type = "bigint"
    }
    columns {
      name = "conversation_id"
      type = "string"
    }
    columns {
      name = "user_arn"
      type = "string"
    }
    columns {
      name = "resource_id"
      type = "string"
    }
    columns {
      name = "resource_type"
      type = "string"
    }
  }
}
