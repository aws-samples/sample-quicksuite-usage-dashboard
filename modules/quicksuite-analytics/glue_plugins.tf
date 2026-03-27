# Plugin utilization table — Parquet, partition projection year/month/day
resource "aws_glue_catalog_table" "plugin_utilization" {
  name          = "plugin_utilization"
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
    "storage.location.template"   = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched_plugins/year=$${year}/month=$${month}/day=$${day}/"
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
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/enriched_plugins/"
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
      name = "plugin_id"
      type = "string"
    }
  }
}
