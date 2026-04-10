variable "quicksight_admin_group" {
  description = "QuickSight group for dashboard/dataset permissions"
  type        = string
}

variable "quicksight_namespace" {
  description = "QuickSight namespace"
  type        = string
  default     = "default"
}

variable "s3_kms_key_arn" {
  description = "ARN of a customer-managed KMS key for S3 bucket encryption. If null, AES256 (SSE-S3) is used."
  type        = string
  default     = null
}

variable "spice_enabled" {
  description = "Enable SPICE caching for QuickSight dataset"
  type        = bool
  default     = true
}

variable "spice_refresh_interval" {
  description = "SPICE incremental refresh interval (MINUTE15, MINUTE30, HOURLY, DAILY)"
  type        = string
  default     = "MINUTE15"
}

variable "quicksight_service_role_name" {
  description = "Name of the existing QuickSight service IAM role"
  type        = string
  default     = "aws-quicksight-service-role-v0"
}

variable "identity_store_id" {
  description = "IAM Identity Center Identity Store ID"
  type        = string
}

variable "identity_store_role_arn" {
  description = "ARN of an IAM role in the management account to assume for Identity Store API calls. Required for cross-account setups (e.g., Control Tower). When null, calls Identity Store directly (same-account)."
  type        = string
  default     = null
}

variable "lambda_layer_arn" {
  description = "ARN of a pre-built Lambda layer containing boto3 and pyarrow. When provided, skips Docker build and uses this layer for all functions."
  type        = string
  default     = null
}

variable "cloudtrail_mode" {
  description = "CloudTrail integration mode for asset tracking: 'new' (create trail), 'existing' (use existing bucket), or 'disabled'"
  type        = string
  default     = "new"
  validation {
    condition     = contains(["new", "existing", "disabled"], var.cloudtrail_mode)
    error_message = "cloudtrail_mode must be 'new', 'existing', or 'disabled'."
  }
}

variable "cloudtrail_config" {
  description = "Configuration for existing CloudTrail integration (used when cloudtrail_mode = 'existing')"
  type = object({
    s3_bucket = string
    org_id    = optional(string)
    s3_prefix = optional(string)
  })
  default = null
  validation {
    condition     = var.cloudtrail_mode != "existing" || (var.cloudtrail_config != null && var.cloudtrail_config.s3_bucket != "")
    error_message = "cloudtrail_config with s3_bucket is required when cloudtrail_mode = 'existing'."
  }
}

variable "user_tier_config" {
  description = "User segmentation tier configuration"
  type = object({
    power_min_messages   = number
    regular_min_messages = number
    casual_min_messages  = number
    power_percentile     = number
    regular_percentile   = number
    dormant_days         = number
    churned_days         = number
  })
  default = {
    power_min_messages   = 300
    regular_min_messages = 150
    casual_min_messages  = 1
    power_percentile     = 10
    regular_percentile   = 30
    dormant_days         = 30
    churned_days         = 60
  }
}

variable "categorization_config" {
  description = "Bedrock message categorization configuration. For large orgs (10K+ messages/hour), increase max_concurrency to 20-50."
  type = object({
    enabled         = bool
    model_id        = string
    bedrock_region  = string
    max_concurrency = number
  })
  default = {
    enabled         = false
    model_id        = "global.amazon.nova-2-lite-v1:0"
    bedrock_region  = "us-east-1"
    max_concurrency = 5
  }
}

variable "categorization_taxonomy_file" {
  description = "Path to custom taxonomy JSON file (DynamoDB JSON format). If null, uses built-in default at config/default_taxonomy.json."
  type        = string
  default     = null
}

variable "qs_metadata_sync_interval" {
  description = "QuickSight metadata sync frequency (MINUTE15, MINUTE30, HOURLY, HOURS6, DAILY)"
  type        = string
  default     = "DAILY"
  validation {
    condition     = contains(["MINUTE15", "MINUTE30", "HOURLY", "HOURS6", "DAILY"], var.qs_metadata_sync_interval)
    error_message = "qs_metadata_sync_interval must be one of: MINUTE15, MINUTE30, HOURLY, HOURS6, DAILY."
  }
}

variable "user_sync_interval" {
  description = "User sync frequency (MINUTE15, MINUTE30, HOURLY, HOURS6, DAILY)"
  type        = string
  default     = "HOURS6"
  validation {
    condition     = contains(["MINUTE15", "MINUTE30", "HOURLY", "HOURS6", "DAILY"], var.user_sync_interval)
    error_message = "user_sync_interval must be one of: MINUTE15, MINUTE30, HOURLY, HOURS6, DAILY."
  }
}

variable "qs_metadata_lambda_memory" {
  description = "Memory (MB) for QuickSight metadata collector Lambdas. Increase for accounts with 10K+ datasets."
  type        = number
  default     = 256
}
