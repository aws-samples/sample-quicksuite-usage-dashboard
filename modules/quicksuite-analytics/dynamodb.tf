resource "aws_dynamodb_table" "categorizer_config" {
  count        = var.categorization_config.enabled ? 1 : 0
  name         = "quicksuite-categorizer-config"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "config_id"

  attribute {
    name = "config_id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}

resource "aws_dynamodb_table_item" "default_config" {
  count      = var.categorization_config.enabled ? 1 : 0
  table_name = aws_dynamodb_table.categorizer_config[0].name
  hash_key   = aws_dynamodb_table.categorizer_config[0].hash_key

  item = var.categorization_taxonomy_file != null ? file(var.categorization_taxonomy_file) : file("${path.module}/config/default_taxonomy.json")
}
