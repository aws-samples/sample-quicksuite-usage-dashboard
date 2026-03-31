# quicksuite-analytics

Terraform module that collects Amazon Quick Suite usage logs, classifies messages with Bedrock, syncs user and QuickSight metadata, and surfaces adoption metrics through a QuickSight dashboard with 5 tabs and 80+ visuals.

## What it does

Deploys a complete analytics pipeline for Amazon Quick Suite (Q Business):

1. **Collects** three types of CloudWatch vended logs (chat, feedback, agent hours) into S3
2. **Classifies** each chat message with Bedrock Nova 2 Lite across three dimensions: prompt category, action intent, and customer information detection
3. **Enriches** log data through a Step Functions ETL pipeline (extracts messages, resource selections, plugin utilization, writes Parquet)
4. **Syncs** user profiles from IAM Identity Center and QuickSight roles (configurable interval, default every 6 hours)
5. **Collects** QuickSight metadata --- datasets, dashboards, analyses, datasources, and SPICE capacity metrics (configurable interval, default daily)
6. **Tracks** asset creation via CloudTrail (spaces, knowledge bases, flows, agents, document uploads)
7. **Restricts** PII-containing S3 prefixes (`AWSLogs/*`, `temp/*`) to ETL pipeline roles only --- console and CLI users cannot access raw message text
8. **Visualizes** everything in a QuickSight dashboard with 5 tabs and 80+ visuals

## Dashboard

Five tabs, each answering different questions:

**Summary** --- "What's happening right now?"
- MAU/WAU/DAU message trends
- Queries & conversations (4 KPIs + combo chart, feedback trend, scope analysis)
- Agent hours usage by subscription tier (Professional vs Enterprise)
- Hours distribution and allotment tracking

**Dive Deep** --- "Who's using it and how?"
- User activity by department, country, and individual
- User segmentation tiers (Power/Regular/Casual/Dormant/Churned)
- Usage patterns by hour of day, day of week
- Plugin utilization, resource selection, and feedback breakdowns
- License cost analysis (unused licenses, agent hours by user)

**Asset Inventory** --- "What assets exist?"
- *Amazon Quick Assets*: spaces, knowledge bases, flows, agents, documents (from CloudTrail)
- *QuickSight BI Assets*: dashboards, analyses, datasets, datasources (from QuickSight API)
- Asset relationship mappings (dashboard→dataset, dataset→datasource)
- Datasource type distribution, analysis status, orphaned datasets

**Usage Insights** --- "What are people asking about?"
- Prompt category distribution (13 categories: HR, Finance, IT, Data/Analytics, etc.)
- Action intent distribution (17 intents: Question Answering, Code Generation, Summarization, etc.)
- Category × Intent heatmap, category trends over time
- Customer information detection (% of messages containing PII)
- Top users by messages, top users by conversations, idle users

**SPICE & Data Health** --- "Is QuickSight healthy?"
- SPICE capacity utilization (% used, trend over time)
- Dataset ingestion status (completed vs failed)
- Failed ingestion details, refresh latency per dataset
- Top SPICE consumers, rows ingested vs dropped
- Datasets by import mode (SPICE vs DIRECT_QUERY)

## Usage

```hcl
data "aws_ssoadmin_instances" "this" {}

module "quicksuite_analytics" {
  source = "github.com/aws-samples/sample-quicksuite-usage-dashboard//modules/quicksuite-analytics"

  quicksight_admin_group = "qs-admins"
  identity_store_id      = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  # Enable Bedrock message categorization
  categorization_config = {
    enabled         = true
    model_id        = "global.amazon.nova-2-lite-v1:0"
    bedrock_region  = "us-east-1"
    max_concurrency = 5
  }
}
```

The module creates all infrastructure: S3 bucket, CloudWatch log delivery, Lambda functions, Step Functions pipelines, DynamoDB config, Glue catalog, QuickSight datasets, and the full dashboard.

To pin to a specific commit (recommended for production):

```hcl
  source = "github.com/aws-samples/sample-quicksuite-usage-dashboard//modules/quicksuite-analytics?ref=COMMIT_SHA"
```

## Requirements

- Terraform >= 1.9
- AWS provider ~> 6.0
- Active Amazon Quick Suite instance (Enterprise or Professional edition)
- IAM Identity Center configured
- QuickSight Enterprise edition with an admin group
- Docker (for building the Lambda layer at `terraform apply` time, unless `lambda_layer_arn` is provided)
- Bedrock model access (if categorization enabled): `global.amazon.nova-2-lite-v1:0` in configured region

## Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `quicksight_admin_group` | string | *required* | QuickSight group for dashboard permissions |
| `identity_store_id` | string | *required* | IAM Identity Center Identity Store ID |
| `quicksight_namespace` | string | `"default"` | QuickSight namespace |
| `s3_kms_key_arn` | string | `null` | Optional KMS key for S3 encryption (AES256 if null) |
| `spice_enabled` | bool | `true` | Enable SPICE caching (recommended for production) |
| `spice_refresh_interval` | string | `"MINUTE15"` | Incremental SPICE refresh: MINUTE15, MINUTE30, HOURLY, DAILY |
| `quicksight_service_role_name` | string | `"aws-quicksight-service-role-v0"` | Existing QuickSight service IAM role name |
| `cloudtrail_mode` | string | `"new"` | `"new"` = create trail, `"existing"` = use existing bucket, `"disabled"` = skip asset tracking |
| `cloudtrail_config` | object | `null` | Configuration for existing CloudTrail: `{ s3_bucket, org_id?, s3_prefix? }`. Required when `cloudtrail_mode = "existing"` |
| `user_tier_config` | object | see below | User segmentation thresholds and percentiles |
| `categorization_config` | object | see below | Bedrock message categorization settings |
| `categorization_taxonomy_file` | string | `null` | Path to custom taxonomy JSON (DynamoDB format). Uses built-in default if null |
| `qs_metadata_sync_interval` | string | `"DAILY"` | QuickSight metadata sync: MINUTE15, MINUTE30, HOURLY, HOURS6, DAILY |
| `user_sync_interval` | string | `"HOURS6"` | User sync frequency: MINUTE15, MINUTE30, HOURLY, HOURS6, DAILY |
| `qs_metadata_lambda_memory` | number | `256` | Memory (MB) for metadata collectors. Increase for 10K+ datasets |
| `lambda_layer_arn` | string | `null` | ARN of a pre-built Lambda layer (boto3 + pyarrow). Skips Docker build when provided. Format: `arn:aws:lambda:REGION:ACCOUNT:layer:LAYER_NAME:VERSION` |

### QuickSight service role

The `quicksight_service_role_name` must be the IAM role that QuickSight uses in your account. The module automatically attaches the required S3 read permissions to this role --- you do not need to configure permissions manually.

To find your role name, go to the QuickSight console: **Manage QuickSight → Security & permissions → QuickSight access to AWS services**. Common names include `aws-quicksight-service-role-v0` (default), `aws-quicksight-s3-consumers-role-v0`, or a custom name your organization created.

The module attaches these inline policies to the role:
- **`QuickSightS3Access-quicksuite`** --- read access to the quicksuite-logs S3 bucket (+ KMS decrypt if `s3_kms_key_arn` is set)
- **`QuickSightCloudTrailAccess-quicksuite`** --- read access to the CloudTrail S3 bucket (only when `cloudtrail_mode = "existing"`)

### Pre-built Lambda layer

If Docker is not available in your deployment environment (e.g., CI/CD pipelines), you can pre-build the layer externally and pass its ARN:

```hcl
lambda_layer_arn = "arn:aws:lambda:eu-west-1:123456789012:layer:quicksuite-dependencies:1"
```

The layer must contain `boto3` and `pyarrow` for Python 3.14 ARM64. Build it using the Dockerfile in `modules/quicksuite-analytics/lambda/dependencies_layer/`:

```bash
cd modules/quicksuite-analytics/lambda/dependencies_layer
docker build --platform linux/arm64 -t quicksuite-layer .
container_id=$(docker create quicksuite-layer)
docker cp $container_id:/opt/python ./python && docker rm $container_id
zip -r layer.zip python && rm -rf python

aws lambda publish-layer-version \
  --layer-name quicksuite-dependencies \
  --zip-file fileb://layer.zip \
  --compatible-runtimes python3.14 \
  --compatible-architectures arm64 \
  --region eu-west-1
```

Use the returned `LayerVersionArn` as the `lambda_layer_arn` value.

### Categorization configuration

When enabled, each chat message is classified by Bedrock across three dimensions: prompt category (13 options), action intent (17 options), and whether it contains customer information. The taxonomy is configurable --- provide a custom JSON file via `categorization_taxonomy_file` or use the built-in default (81 few-shot examples).

```hcl
categorization_config = {
  enabled         = true
  model_id        = "global.amazon.nova-2-lite-v1:0"
  bedrock_region  = "us-east-1"   # Region where Bedrock model is accessible
  max_concurrency = 5              # Distributed Map concurrency (increase to 20-50 for large orgs)
}
```

When disabled (default), messages are tagged "Uncategorized" and no Bedrock calls are made.

### User tier configuration

Users are classified into tiers using a threshold + percentile model. The threshold is the minimum message count to qualify. The percentile determines actual placement among qualifying users.

```hcl
user_tier_config = {
  power_min_messages   = 300   # minimum monthly messages to qualify for Power
  regular_min_messages = 150   # minimum for Regular
  casual_min_messages  = 1     # minimum for Casual
  power_percentile     = 10    # top 10% of qualifying users = Power
  regular_percentile   = 30    # next 30% = Regular
  dormant_days         = 30    # no activity = Dormant
  churned_days         = 60    # no activity = Churned
}
```

### Cross-account CloudTrail setup

If your organization uses a central logging account (common with AWS Control Tower), set `cloudtrail_mode = "existing"` and provide the bucket name:

**Same-account, existing trail:**
```hcl
cloudtrail_mode   = "existing"
cloudtrail_config = {
  s3_bucket = "my-cloudtrail-bucket"
}
```

**Cross-account (e.g., Control Tower log archive):**
```hcl
cloudtrail_mode   = "existing"
cloudtrail_config = {
  s3_bucket = "aws-controltower-logs-LOGACCOUNT-eu-west-1"
}
```

After deploying, retrieve the bucket policy statement the logging account admin needs to add:

```bash
terraform output -raw cloudtrail_cross_account_bucket_policy | jq .
```

This outputs a ready-to-use JSON policy statement with your account ID, QuickSight role, and bucket pre-filled. The logging account admin adds this as a statement in their bucket policy.

If the bucket uses a customer-managed KMS key, the logging account must also grant decrypt access:

```json
{
  "Sid": "AllowQuickSuiteDecrypt",
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::QUICKSUITE_ACCOUNT:role/QUICKSIGHT_SERVICE_ROLE"
  },
  "Action": "kms:Decrypt",
  "Resource": "*"
}
```

**Organization trail (org ID in S3 path):**
```hcl
cloudtrail_mode   = "existing"
cloudtrail_config = {
  s3_bucket = "central-logging-bucket"
  org_id    = "o-abc123def4"
}
```

**Custom prefix (non-standard path):**
```hcl
cloudtrail_mode   = "existing"
cloudtrail_config = {
  s3_bucket  = "central-logging-bucket"
  s3_prefix  = "custom/AWSLogs/o-abc123/123456789012/CloudTrail/eu-west-1"
}
```

## Architecture

```
CloudWatch Vended Logs (CHAT, FEEDBACK, AGENT_HOURS)
  --> S3 bucket (PII prefixes restricted to pipeline roles)
  --> S3 event notification --> Lambda trigger --> Step Functions
        |
        +--> Parse (extract 3 log types + resource selections + plugins)
        +--> Categorize (Bedrock Nova 2 Lite, Distributed Map per message)
        +--> Write Parquet (enriched/, enriched_agent_hours/, enriched_feedback/,
        |                   enriched_resource_selections/, enriched_plugins/)
        |
        v
      Glue tables (partition projection, zero partition management)
        |
        v
      Athena --> QuickSight datasets (SPICE) --> Dashboard (5 tabs, 80+ visuals)

IAM Identity Center + QuickSight API
  --> User sync SFN (configurable interval, Distributed Map for 10k+ users)
  --> user_attributes/users.jsonl (JSONL with tier computation)

QuickSight API + CloudWatch
  --> QS metadata sync SFN (configurable interval, 3 Distributed Map branches)
  --> qs_metadata/ (datasets, dashboards, analyses, datasources, SPICE capacity)

CloudTrail (optional)
  --> S3 bucket (same bucket, /CloudTrail/ prefix)
  --> Glue table (partition projection) --> QuickSight dataset

Bedrock categorization config
  --> DynamoDB (taxonomy: categories, intents, few-shot examples)
  --> Configurable via Terraform variable or custom JSON file
```

### Data pipeline

| Data Type | S3 Prefix | Format | Partitions |
|-----------|-----------|--------|------------|
| Chat messages (enriched) | `enriched/` | Parquet | year/month/day |
| Agent hours | `enriched_agent_hours/` | Parquet | year/month/day |
| Feedback | `enriched_feedback/` | Parquet | year/month/day |
| Resource selections | `enriched_resource_selections/` | Parquet | year/month/day |
| Plugin utilization | `enriched_plugins/` | Parquet | year/month/day |
| User attributes | `user_attributes/` | JSONL | none (overwrite) |
| QS datasets metadata | `qs_metadata/datasets/` | JSONL | none (overwrite) |
| QS dashboards metadata | `qs_metadata/dashboards/` | JSONL | none (overwrite) |
| QS analyses metadata | `qs_metadata/analyses/` | JSONL | none (overwrite) |
| QS datasources metadata | `qs_metadata/datasources/` | JSONL | none (overwrite) |
| SPICE capacity metrics | `qs_metadata/spice_capacity/` | Parquet | year/month/day |
| CloudTrail events | Raw JSON (queried directly) | JSON | year/month/day |

All Glue tables use **partition projection** --- Athena computes partitions from the S3 path pattern, so there is no Lambda, DynamoDB, or Athena DDL needed for partition discovery.

### Lambda functions

| Function | Purpose | Runtime |
|----------|---------|---------|
| `quicksuite-sfn-trigger` | S3 event --> start Step Functions | Python 3.14 ARM64 |
| `quicksuite-log-parser` | Extract 3 log types, derive query_scope, extract resources + plugins | Python 3.14 ARM64 |
| `quicksuite-message-categorizer` | Classify messages via Bedrock (enabled) or inject defaults (disabled) | Python 3.14 ARM64 |
| `quicksuite-result-writer` | Write Parquet, handle Distributed Map results | Python 3.14 ARM64 |
| `quicksuite-user-idc-list` | List IAM Identity Center users | Python 3.14 ARM64 |
| `quicksuite-user-idc-describe` | Describe user with enterprise extension | Python 3.14 ARM64 |
| `quicksuite-user-qs-list` | List QuickSight users with roles | Python 3.14 ARM64 |
| `quicksuite-user-merge` | Merge IDC + QS data, derive license type, compute user tiers | Python 3.14 ARM64 |
| `quicksuite-qs-list-datasets` | Paginate QuickSight list_data_sets | Python 3.14 ARM64 |
| `quicksuite-qs-describe-dataset` | Per-dataset: describe + permissions + ingestions | Python 3.14 ARM64 |
| `quicksuite-qs-list-dashboards` | Paginate QuickSight list_dashboards | Python 3.14 ARM64 |
| `quicksuite-qs-describe-dashboard` | Per-dashboard: describe + dataset mappings | Python 3.14 ARM64 |
| `quicksuite-qs-list-analyses` | Paginate QuickSight list_analyses | Python 3.14 ARM64 |
| `quicksuite-qs-describe-analysis` | Per-analysis: describe + dataset mappings | Python 3.14 ARM64 |
| `quicksuite-qs-write-metadata` | Read Distributed Map results, write final JSONL | Python 3.14 ARM64 |
| `quicksuite-qs-collect-datasources` | Discover datasources + dataset mappings | Python 3.14 ARM64 |
| `quicksuite-qs-collect-spice` | CloudWatch SPICE capacity metrics --> Parquet | Python 3.14 ARM64 |

### S3 security

The S3 bucket policy includes explicit Deny statements on PII-containing prefixes (`AWSLogs/*` and `temp/*`). Only the ETL pipeline IAM roles (Lambda + SFN) are allowlisted via `aws:PrincipalArn` condition. Console users, CLI users, and any non-pipeline roles receive `AccessDenied` when attempting to read or list raw message data. CloudWatch log delivery (`s3:PutObject`) is unaffected.

## Outputs

| Output | Description |
|--------|-------------|
| `bucket_name` | S3 bucket name |
| `bucket_arn` | S3 bucket ARN |
| `dashboard_id` | QuickSight dashboard ID |
| `user_sync_sfn_arn` | User sync state machine ARN |
| `cloudtrail_cross_account_bucket_policy` | Ready-to-use bucket policy JSON for cross-account CloudTrail (null when not applicable) |

## Development

```bash
git clone <repo>
cd amazon-quicksuite-dashboard-v2

# Edit main.tf with your profile/region/admin group
terraform init
terraform plan
terraform apply

# Run unit tests (69 tests)
make test

# Validate Terraform
make validate

# Build Lambda layer (requires Docker)
make build-layer

# Full check (validate + test + lint)
make check

# Trigger user sync manually
aws stepfunctions start-execution \
  --state-machine-arn "$(terraform output -raw user_sync_sfn_arn)" \
  --input '{"source": "manual"}' \
  --profile your-profile --region eu-west-1

# Trigger SPICE refresh
aws quicksight create-ingestion \
  --aws-account-id $(aws sts get-caller-identity --query Account --output text) \
  --data-set-id quicksuite-messages \
  --ingestion-id "manual-$(date +%s)" \
  --ingestion-type FULL_REFRESH \
  --profile your-profile --region eu-west-1
```

### Project layout

```
main.tf                           # Local dev entry point
modules/quicksuite-analytics/     # The distributable module
  lambda/                         # 17 Lambda functions
  config/                         # Default categorization taxonomy JSON
  *.tf                            # ~34 Terraform files (service-prefixed)
test/unit/                        # 69 unit tests (pytest)
docs/superpowers/specs/           # Design specs (Features 1-7)
docs/superpowers/plans/           # Implementation plans
```

### Terraform file naming

Files follow a service-prefix convention:

| Prefix | Contents |
|--------|----------|
| `lambda_*.tf` | Lambda functions and layers |
| `sfn_*.tf` | Step Functions state machines |
| `iam_*.tf` | IAM roles and policies |
| `eventbridge_*.tf` | EventBridge rules and targets |
| `glue_*.tf` | Glue catalog tables |
| `quicksight_*.tf` | QuickSight resources (datasets, dashboard) |
| `dynamodb.tf` | Categorizer config table |
| `cloudtrail.tf` | CloudTrail trail |
| `cloudwatch_delivery.tf` | CloudWatch log delivery |
| `s3.tf` | S3 bucket + PII access restrictions |

## Known limitations

- **Agent names not resolved** --- custom agent UUIDs display as-is (no `list_agents` API). `SYSTEM` is labeled "Default Assistant".
- **Space names not resolved** --- only space UUIDs are captured. No `list_spaces` API exists.
- **No idempotency on reprocessing** --- re-running ETL on existing log files creates duplicate Parquet files. Clean the `enriched/` prefix before reprocessing.
- **User tier requires Athena** --- the tier computation queries Athena during user sync. If Athena is unavailable, all users get tier "Unknown".
- **CloudTrail historical gap** --- only captures events from trail creation onward. Pre-existing assets appear when updated.
- **Idle users table uses fixed 90-day window** --- the idle users table on Usage Insights always shows users with no messages in the last 90 days, regardless of the date filter selection.
- **SPICE capacity metrics** --- CloudWatch `AWS/QuickSight` metrics may take time to populate for new accounts.
- **Bedrock response parsing** --- Nova 2 Lite wraps JSON responses in markdown code fences. The categorizer strips these, but other models may need adaptation.

## License

Apache-2.0
