# QS Datasets metadata table — JSONL, no partitions
resource "aws_glue_catalog_table" "qs_datasets" {
  name          = "qs_datasets"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/qs_metadata/datasets/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "dataset_id"
      type = "string"
    }
    columns {
      name = "name"
      type = "string"
    }
    columns {
      name = "import_mode"
      type = "string"
    }
    columns {
      name = "last_updated_time"
      type = "string"
    }
    columns {
      name = "consumed_spice_bytes"
      type = "bigint"
    }
    columns {
      name = "rows_ingested"
      type = "bigint"
    }
    columns {
      name = "rows_dropped"
      type = "bigint"
    }
    columns {
      name = "ingestion_status"
      type = "string"
    }
    columns {
      name = "refresh_triggered_time"
      type = "string"
    }
    columns {
      name = "refresh_time_seconds"
      type = "double"
    }
    columns {
      name = "request_source"
      type = "string"
    }
    columns {
      name = "request_type"
      type = "string"
    }
    columns {
      name = "error_type"
      type = "string"
    }
    columns {
      name = "error_message"
      type = "string"
    }
    columns {
      name = "permission_count"
      type = "bigint"
    }
    columns {
      name = "is_orphaned"
      type = "string"
    }
    columns {
      name = "synced_at"
      type = "string"
    }
  }
}

# QS Dashboards metadata table — JSONL, no partitions
resource "aws_glue_catalog_table" "qs_dashboards" {
  name          = "qs_dashboards"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/qs_metadata/dashboards/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "dashboard_id"
      type = "string"
    }
    columns {
      name = "dashboard_name"
      type = "string"
    }
    columns {
      name = "dataset_id"
      type = "string"
    }
    columns {
      name = "dataset_name"
      type = "string"
    }
    columns {
      name = "dataset_last_updated_time"
      type = "string"
    }
    columns {
      name = "dataset_created_time"
      type = "string"
    }
    columns {
      name = "synced_at"
      type = "string"
    }
  }
}

# QS Analyses metadata table — JSONL, no partitions
resource "aws_glue_catalog_table" "qs_analyses" {
  name          = "qs_analyses"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/qs_metadata/analyses/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "analysis_id"
      type = "string"
    }
    columns {
      name = "analysis_name"
      type = "string"
    }
    columns {
      name = "status"
      type = "string"
    }
    columns {
      name = "dataset_id"
      type = "string"
    }
    columns {
      name = "dataset_name"
      type = "string"
    }
    columns {
      name = "dataset_last_updated_time"
      type = "string"
    }
    columns {
      name = "dataset_created_time"
      type = "string"
    }
    columns {
      name = "synced_at"
      type = "string"
    }
  }
}

# QS Datasources metadata table — JSONL, no partitions
resource "aws_glue_catalog_table" "qs_datasources" {
  name          = "qs_datasources"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/qs_metadata/datasources/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "datasource_id"
      type = "string"
    }
    columns {
      name = "datasource_name"
      type = "string"
    }
    columns {
      name = "datasource_type"
      type = "string"
    }
    columns {
      name = "dataset_id"
      type = "string"
    }
    columns {
      name = "dataset_name"
      type = "string"
    }
    columns {
      name = "dataset_last_updated_time"
      type = "string"
    }
    columns {
      name = "dataset_created_time"
      type = "string"
    }
    columns {
      name = "synced_at"
      type = "string"
    }
  }
}

# QS SPICE capacity table — Parquet with partition projection (year/month/day)
resource "aws_glue_catalog_table" "qs_spice_capacity" {
  name          = "qs_spice_capacity"
  database_name = aws_glue_catalog_database.quicksuite.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    "classification"            = "parquet"
    "projection.enabled"        = "true"
    "projection.year.type"      = "integer"
    "projection.year.range"     = "2024,2030"
    "projection.year.digits"    = "4"
    "projection.month.type"     = "integer"
    "projection.month.range"    = "1,12"
    "projection.month.digits"   = "2"
    "projection.day.type"       = "integer"
    "projection.day.range"      = "1,31"
    "projection.day.digits"     = "2"
    "storage.location.template" = "s3://${aws_s3_bucket.quicksuite_logs.id}/qs_metadata/spice_capacity/year=$${year}/month=$${month}/day=$${day}/"
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
    location      = "s3://${aws_s3_bucket.quicksuite_logs.id}/qs_metadata/spice_capacity/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "timestamp"
      type = "bigint"
    }
    columns {
      name = "spice_limit_mb"
      type = "double"
    }
    columns {
      name = "spice_consumed_mb"
      type = "double"
    }
  }
}
