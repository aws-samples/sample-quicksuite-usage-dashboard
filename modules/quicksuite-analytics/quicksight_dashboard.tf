locals {
  kpi_title = {
    total_messages       = "<visual-title>\n  <inline font-size=\"20px\">Total Messages</inline>\n</visual-title>"
    mau                  = "<visual-title>\n  <inline font-size=\"20px\">Trending this month</inline>\n</visual-title>"
    wau                  = "<visual-title>\n  <inline font-size=\"20px\">Trending this week</inline>\n</visual-title>"
    dau                  = "<visual-title>\n  <inline font-size=\"20px\">Trending today</inline>\n</visual-title>"
    professional_hours   = "<visual-title>\n  <inline font-size=\"20px\">Professional Hours</inline>\n</visual-title>"
    enterprise_hours     = "<visual-title>\n  <inline font-size=\"20px\">Enterprise Hours</inline>\n</visual-title>"
    additional_hours     = "<visual-title>\n  <inline font-size=\"20px\">Additional Hours</inline>\n</visual-title>"
    hours_distribution   = "<visual-title>\n  <inline font-size=\"20px\">Hours by Subscription Type</inline>\n</visual-title>"
    additional_hours_trend           = "<visual-title>\n  <inline font-size=\"20px\">Additional Hours by Week</inline>\n</visual-title>"
    total_conversations              = "<visual-title>\n  <inline font-size=\"20px\">Total Conversations</inline>\n</visual-title>"
    total_queries                    = "<visual-title>\n  <inline font-size=\"20px\">Total Queries</inline>\n</visual-title>"
    avg_queries_per_user             = "<visual-title>\n  <inline font-size=\"20px\">Avg Queries per User</inline>\n</visual-title>"
    avg_queries_per_conversation     = "<visual-title>\n  <inline font-size=\"20px\">Avg Queries per Conversation</inline>\n</visual-title>"
    conversations_queries_users      = "<visual-title>\n  <inline font-size=\"20px\">Conversations, Queries &amp; Active Users</inline>\n</visual-title>"
    avg_queries_chart                = "<visual-title>\n  <inline font-size=\"20px\">Avg Queries per Conversation</inline>\n</visual-title>"
    feedback_trend                   = "<visual-title>\n  <inline font-size=\"20px\">Customer Feedback Trend</inline>\n</visual-title>"
    query_scope_chart                = "<visual-title>\n  <inline font-size=\"20px\">Query Scope Selection</inline>\n</visual-title>"
  }
  kpi_subtitle = {
    total_messages       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Chat messages in selected period</inline>\n</visual-subtitle>"
    mau                  = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Messages in last 30 days (MAU)</inline>\n</visual-subtitle>"
    wau                  = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Messages in last 7 days (WAU)</inline>\n</visual-subtitle>"
    dau                  = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Messages today (DAU)</inline>\n</visual-subtitle>"
    professional_hours   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Total Professional license hours this month</inline>\n</visual-subtitle>"
    enterprise_hours     = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Total Enterprise license hours this month</inline>\n</visual-subtitle>"
    additional_hours     = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Hours exceeding allotment this month</inline>\n</visual-subtitle>"
    hours_distribution   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Users by % of allotment consumed</inline>\n</visual-subtitle>"
    additional_hours_trend           = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Extra usage hours per week</inline>\n</visual-subtitle>"
    total_conversations              = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Unique conversations in selected period</inline>\n</visual-subtitle>"
    total_queries                    = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Total chat queries in selected period</inline>\n</visual-subtitle>"
    avg_queries_per_user             = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Average queries per active user</inline>\n</visual-subtitle>"
    avg_queries_per_conversation     = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Average queries per conversation</inline>\n</visual-subtitle>"
    conversations_queries_users      = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Monthly breakdown of conversations, queries, and active users</inline>\n</visual-subtitle>"
    avg_queries_chart                = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Total queries per month (per-conversation avg configurable in console)</inline>\n</visual-subtitle>"
    feedback_trend                   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Feedback responses by type per month</inline>\n</visual-subtitle>"
    query_scope_chart                = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Queries by resource scope selection per month</inline>\n</visual-subtitle>"
  }
  qs_principal = "arn:aws:quicksight:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:group/${var.quicksight_namespace}/${var.quicksight_admin_group}"

  # Asset Inventory tab titles and subtitles
  asset_kpi_title = {
    spaces    = "<visual-title>\n  <inline font-size=\"20px\">Total Spaces</inline>\n</visual-title>"
    kbs       = "<visual-title>\n  <inline font-size=\"20px\">Total Knowledge Bases</inline>\n</visual-title>"
    flows     = "<visual-title>\n  <inline font-size=\"20px\">Total Flows</inline>\n</visual-title>"
    agents    = "<visual-title>\n  <inline font-size=\"20px\">Total Agents</inline>\n</visual-title>"
    documents = "<visual-title>\n  <inline font-size=\"20px\">Total Documents</inline>\n</visual-title>"
  }
  asset_kpi_subtitle = {
    spaces    = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Spaces created in selected period</inline>\n</visual-subtitle>"
    kbs       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Knowledge Bases created in selected period</inline>\n</visual-subtitle>"
    flows     = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Flows created in selected period</inline>\n</visual-subtitle>"
    agents    = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Agents created in selected period</inline>\n</visual-subtitle>"
    documents = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Documents created in selected period</inline>\n</visual-subtitle>"
  }
  asset_chart_title = {
    creation_trend     = "<visual-title>\n  <inline font-size=\"20px\">Asset Creation Trend</inline>\n</visual-title>"
    type_breakdown     = "<visual-title>\n  <inline font-size=\"20px\">Asset Type Breakdown</inline>\n</visual-title>"
    top_creators       = "<visual-title>\n  <inline font-size=\"20px\">Top Asset Creators</inline>\n</visual-title>"
    kb_by_type         = "<visual-title>\n  <inline font-size=\"20px\">KB by Type</inline>\n</visual-title>"
    top_uploaders      = "<visual-title>\n  <inline font-size=\"20px\">Top Uploaders by Size</inline>\n</visual-title>"
    upload_trend       = "<visual-title>\n  <inline font-size=\"20px\">Upload Trend</inline>\n</visual-title>"
    largest_uploads    = "<visual-title>\n  <inline font-size=\"20px\">Largest Uploads</inline>\n</visual-title>"
    uploads_by_type    = "<visual-title>\n  <inline font-size=\"20px\">Uploads by Content Type</inline>\n</visual-title>"
    spaces_over_time   = "<visual-title>\n  <inline font-size=\"20px\">Spaces Created Over Time</inline>\n</visual-title>"
    mods_vs_creates    = "<visual-title>\n  <inline font-size=\"20px\">Asset Modifications vs Creations</inline>\n</visual-title>"
  }
  asset_chart_subtitle = {
    creation_trend     = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Monthly asset creation by type</inline>\n</visual-subtitle>"
    type_breakdown     = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Distribution of created assets by type</inline>\n</visual-subtitle>"
    top_creators       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Users with most asset creations</inline>\n</visual-subtitle>"
    kb_by_type         = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Knowledge Bases by type</inline>\n</visual-subtitle>"
    top_uploaders      = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Users ranked by total upload size (MB)</inline>\n</visual-subtitle>"
    upload_trend       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Monthly upload volume in MB</inline>\n</visual-subtitle>"
    largest_uploads    = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Largest individual file uploads</inline>\n</visual-subtitle>"
    uploads_by_type    = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Upload volume by content type</inline>\n</visual-subtitle>"
    spaces_over_time   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Monthly space creation over time</inline>\n</visual-subtitle>"
    mods_vs_creates    = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Create vs Update operations per month</inline>\n</visual-subtitle>"
  }

  # Categorization tab titles and subtitles
  cat_title = {
    category_distribution = "<visual-title>\n  <inline font-size=\"20px\">Prompt Category Distribution</inline>\n</visual-title>"
    intent_distribution   = "<visual-title>\n  <inline font-size=\"20px\">Action Intent Distribution</inline>\n</visual-title>"
    category_intent_heat  = "<visual-title>\n  <inline font-size=\"20px\">Category x Intent</inline>\n</visual-title>"
    category_trend        = "<visual-title>\n  <inline font-size=\"20px\">Category Trend Over Time</inline>\n</visual-title>"
    customer_info_pie     = "<visual-title>\n  <inline font-size=\"20px\">Contains Customer Info</inline>\n</visual-title>"
    category_by_dept      = "<visual-title>\n  <inline font-size=\"20px\">Top Categories by Department</inline>\n</visual-title>"
    top_by_messages       = "<visual-title>\n  <inline font-size=\"20px\">Top Users by Messages</inline>\n</visual-title>"
    top_by_conversations  = "<visual-title>\n  <inline font-size=\"20px\">Top Users by Conversations</inline>\n</visual-title>"
    idle_users            = "<visual-title>\n  <inline font-size=\"20px\">Idle Users</inline>\n</visual-title>"
  }
  cat_subtitle = {
    category_distribution = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Messages by prompt category</inline>\n</visual-subtitle>"
    intent_distribution   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Messages by action intent</inline>\n</visual-subtitle>"
    category_intent_heat  = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Heatmap of category vs intent combinations</inline>\n</visual-subtitle>"
    category_trend        = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Weekly category trend (top categories)</inline>\n</visual-subtitle>"
    customer_info_pie     = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Percentage of messages containing customer information</inline>\n</visual-subtitle>"
    category_by_dept      = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Category distribution by department</inline>\n</visual-subtitle>"
    top_by_messages       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Users with most messages in selected period</inline>\n</visual-subtitle>"
    top_by_conversations  = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Users with most conversations in selected period</inline>\n</visual-subtitle>"
    idle_users            = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Licensed users with no messages in past 90 days (fixed window, not affected by date filter)</inline>\n</visual-subtitle>"
  }

  # SPICE & Data Health tab titles and subtitles
  spice_title = {
    utilization = "<visual-title>\n  <inline font-size=\"20px\">SPICE Utilization %</inline>\n</visual-title>"
    gauge       = "<visual-title>\n  <inline font-size=\"20px\">SPICE Capacity</inline>\n</visual-title>"
    trend       = "<visual-title>\n  <inline font-size=\"20px\">SPICE Capacity Trend</inline>\n</visual-title>"
    ingestion   = "<visual-title>\n  <inline font-size=\"20px\">Ingestion Status</inline>\n</visual-title>"
    failed      = "<visual-title>\n  <inline font-size=\"20px\">Failed Ingestions</inline>\n</visual-title>"
    latency     = "<visual-title>\n  <inline font-size=\"20px\">Dataset Refresh Latency</inline>\n</visual-title>"
    top_spice   = "<visual-title>\n  <inline font-size=\"20px\">Top Datasets by SPICE</inline>\n</visual-title>"
    rows        = "<visual-title>\n  <inline font-size=\"20px\">Rows Ingested vs Dropped</inline>\n</visual-title>"
    import_mode = "<visual-title>\n  <inline font-size=\"20px\">Datasets by Import Mode</inline>\n</visual-title>"
  }
  spice_subtitle = {
    utilization = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Current SPICE consumed as % of account limit</inline>\n</visual-subtitle>"
    gauge       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">SPICE consumed vs total limit (MB)</inline>\n</visual-subtitle>"
    trend       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">SPICE consumed and limit over time</inline>\n</visual-subtitle>"
    ingestion   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Dataset ingestion results by status</inline>\n</visual-subtitle>"
    failed      = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Datasets with failed ingestions and error details</inline>\n</visual-subtitle>"
    latency     = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Average refresh duration per dataset</inline>\n</visual-subtitle>"
    top_spice   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Datasets consuming the most SPICE capacity</inline>\n</visual-subtitle>"
    rows        = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Rows successfully ingested vs dropped per dataset</inline>\n</visual-subtitle>"
    import_mode = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Distribution of datasets by import mode</inline>\n</visual-subtitle>"
  }

  # QuickSight BI Assets tab titles and subtitles
  bi_asset_title = {
    total_dashboards         = "<visual-title>\n  <inline font-size=\"20px\">Total Dashboards</inline>\n</visual-title>"
    total_analyses           = "<visual-title>\n  <inline font-size=\"20px\">Total Analyses</inline>\n</visual-title>"
    total_datasets           = "<visual-title>\n  <inline font-size=\"20px\">Total Datasets</inline>\n</visual-title>"
    total_datasources        = "<visual-title>\n  <inline font-size=\"20px\">Total Data Sources</inline>\n</visual-title>"
    dashboard_dataset_table  = "<visual-title>\n  <inline font-size=\"20px\">Dashboards &amp; Datasets</inline>\n</visual-title>"
    dataset_datasource_table = "<visual-title>\n  <inline font-size=\"20px\">Datasets &amp; Data Sources</inline>\n</visual-title>"
    datasource_types         = "<visual-title>\n  <inline font-size=\"20px\">Data Source Types</inline>\n</visual-title>"
    analysis_status          = "<visual-title>\n  <inline font-size=\"20px\">Analysis Status</inline>\n</visual-title>"
    orphaned_datasets        = "<visual-title>\n  <inline font-size=\"20px\">Orphaned Datasets</inline>\n</visual-title>"
  }
  bi_asset_subtitle = {
    total_dashboards         = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Published dashboards in this QuickSight account</inline>\n</visual-subtitle>"
    total_analyses           = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Analyses in this QuickSight account</inline>\n</visual-subtitle>"
    total_datasets           = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Distinct datasets referenced by assets</inline>\n</visual-subtitle>"
    total_datasources        = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Data sources in this QuickSight account</inline>\n</visual-subtitle>"
    dashboard_dataset_table  = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Dashboards with their associated dataset names</inline>\n</visual-subtitle>"
    dataset_datasource_table = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Data sources with their linked datasets</inline>\n</visual-subtitle>"
    datasource_types         = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Distribution of data sources by connection type</inline>\n</visual-subtitle>"
    analysis_status          = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Analyses grouped by status</inline>\n</visual-subtitle>"
    orphaned_datasets        = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Datasets not linked to any dashboard or analysis</inline>\n</visual-subtitle>"
  }

  # Dive Deep tab titles
  dd_kpi_title = {
    active_users        = "<visual-title>\n  <inline font-size=\"20px\">Active Users</inline>\n</visual-title>"
    stickiness          = "<visual-title>\n  <inline font-size=\"20px\">Stickiness Ratio</inline>\n</visual-title>"
    active_pct          = "<visual-title>\n  <inline font-size=\"20px\">Active AI Users</inline>\n</visual-title>"
    feedback_rate       = "<visual-title>\n  <inline font-size=\"20px\">Feedback Count</inline>\n</visual-title>"
    unused_total        = "<visual-title>\n  <inline font-size=\"20px\">Unused Licenses (Total)</inline>\n</visual-title>"
    unused_pro          = "<visual-title>\n  <inline font-size=\"20px\">Unused Licenses (Pro)</inline>\n</visual-title>"
    unused_enterprise   = "<visual-title>\n  <inline font-size=\"20px\">Unused Licenses (Enterprise)</inline>\n</visual-title>"
  }
  dd_kpi_subtitle = {
    active_users        = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Distinct users with chat messages in period</inline>\n</visual-subtitle>"
    stickiness          = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Daily active / monthly active ratio</inline>\n</visual-subtitle>"
    active_pct          = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Users who sent at least one AI message</inline>\n</visual-subtitle>"
    feedback_rate       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Total feedback submissions in period</inline>\n</visual-subtitle>"
    unused_total        = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Licensed users with Dormant/Churned/Never Active tier</inline>\n</visual-subtitle>"
    unused_pro          = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Professional users not active in period</inline>\n</visual-subtitle>"
    unused_enterprise   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Enterprise users not active in period</inline>\n</visual-subtitle>"
  }
  dd_chart_title = {
    top_users           = "<visual-title>\n  <inline font-size=\"20px\">Top 20 Users by Messages</inline>\n</visual-title>"
    by_department       = "<visual-title>\n  <inline font-size=\"20px\">Activity by Department</inline>\n</visual-title>"
    by_country          = "<visual-title>\n  <inline font-size=\"20px\">Activity by Country</inline>\n</visual-title>"
    user_activity_table = "<visual-title>\n  <inline font-size=\"20px\">User Activity</inline>\n</visual-title>"
    tier_breakdown      = "<visual-title>\n  <inline font-size=\"20px\">User Tier Breakdown</inline>\n</visual-title>"
    status_dist         = "<visual-title>\n  <inline font-size=\"20px\">Status Distribution</inline>\n</visual-title>"
    blocked_trend       = "<visual-title>\n  <inline font-size=\"20px\">Blocked Requests Trend</inline>\n</visual-title>"
    by_agent            = "<visual-title>\n  <inline font-size=\"20px\">Messages by Agent</inline>\n</visual-title>"
    plugins             = "<visual-title>\n  <inline font-size=\"20px\">Plugin Utilization</inline>\n</visual-title>"
    hour_of_day         = "<visual-title>\n  <inline font-size=\"20px\">Messages by Hour of Day</inline>\n</visual-title>"
    day_of_week         = "<visual-title>\n  <inline font-size=\"20px\">Messages by Day of Week</inline>\n</visual-title>"
    daily_volume        = "<visual-title>\n  <inline font-size=\"20px\">Daily Message Volume</inline>\n</visual-title>"
    top_resources       = "<visual-title>\n  <inline font-size=\"20px\">Top Resources Queried</inline>\n</visual-title>"
    feedback_users      = "<visual-title>\n  <inline font-size=\"20px\">Top 10 Feedback Users</inline>\n</visual-title>"
    resource_type       = "<visual-title>\n  <inline font-size=\"20px\">Resource Type Distribution</inline>\n</visual-title>"
    agent_hours_table   = "<visual-title>\n  <inline font-size=\"20px\">Top 10 Agent Hours by User</inline>\n</visual-title>"
  }
  dd_chart_subtitle = {
    top_users           = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Top 20 users ranked by message count</inline>\n</visual-subtitle>"
    by_department       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Message count by department</inline>\n</visual-subtitle>"
    by_country          = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Message count by country</inline>\n</visual-subtitle>"
    user_activity_table = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Per-user message and conversation counts</inline>\n</visual-subtitle>"
    tier_breakdown      = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Users by activity tier</inline>\n</visual-subtitle>"
    status_dist         = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Message count by status</inline>\n</visual-subtitle>"
    blocked_trend       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Blocked messages over time</inline>\n</visual-subtitle>"
    by_agent            = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Message count by agent</inline>\n</visual-subtitle>"
    plugins             = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Plugin usage count by plugin ID</inline>\n</visual-subtitle>"
    hour_of_day         = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Message distribution across hours 0-23</inline>\n</visual-subtitle>"
    day_of_week         = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Message distribution by day of week</inline>\n</visual-subtitle>"
    daily_volume        = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Daily chat message volume over time</inline>\n</visual-subtitle>"
    top_resources       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Most queried resources in period</inline>\n</visual-subtitle>"
    feedback_users      = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Users with most feedback submissions</inline>\n</visual-subtitle>"
    resource_type       = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Resource selections by type</inline>\n</visual-subtitle>"
    agent_hours_table   = "<visual-subtitle>\n  <inline font-size=\"12px\" color=\"#666666\">Agent hours usage per user</inline>\n</visual-subtitle>"
  }
}

resource "aws_quicksight_analysis" "quicksuite" {
  analysis_id = "quicksuite-analytics"
  name        = "Amazon Quick Suite Adoption"

  definition {
    data_set_identifiers_declarations {
      data_set_arn = aws_quicksight_data_set.messages.arn
      identifier   = "messages"
    }

    dynamic "data_set_identifiers_declarations" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        data_set_arn = aws_quicksight_data_set.asset_inventory[0].arn
        identifier   = "asset-inventory"
      }
    }

    data_set_identifiers_declarations {
      data_set_arn = aws_quicksight_data_set.plugin_utilization.arn
      identifier   = "plugin-utilization"
    }

    data_set_identifiers_declarations {
      data_set_arn = aws_quicksight_data_set.resource_selections.arn
      identifier   = "resource-selections"
    }

    data_set_identifiers_declarations {
      data_set_arn = aws_quicksight_data_set.bi_assets.arn
      identifier   = "bi-assets"
    }

    data_set_identifiers_declarations {
      data_set_arn = aws_quicksight_data_set.dataset_health.arn
      identifier   = "dataset-health"
    }

    data_set_identifiers_declarations {
      data_set_arn = aws_quicksight_data_set.idle_users.arn
      identifier   = "idle-users"
    }

    dynamic "data_set_identifiers_declarations" {
      for_each = var.spice_enabled ? [1] : []
      content {
        data_set_arn = aws_quicksight_data_set.spice_capacity[0].arn
        identifier   = "spice-capacity"
      }
    }

    # --- Summary sheet filters (fixed, no user control) ---

    filter_groups {
      filter_group_id = "mau-filter-group"
      filters {
        relative_dates_filter {
          filter_id = "mau-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Timestamp"
          }
          null_option = "NON_NULLS_ONLY"
          anchor_date_configuration {
            anchor_option = "NOW"
          }
          time_granularity    = "DAY"
          relative_date_type  = "LAST"
          relative_date_value = 30
          minimum_granularity = "DAY"
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-mau"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    filter_groups {
      filter_group_id = "wau-filter-group"
      filters {
        relative_dates_filter {
          filter_id = "wau-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Timestamp"
          }
          null_option = "NON_NULLS_ONLY"
          anchor_date_configuration {
            anchor_option = "NOW"
          }
          time_granularity    = "DAY"
          relative_date_type  = "LAST"
          relative_date_value = 7
          minimum_granularity = "DAY"
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-wau"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    filter_groups {
      filter_group_id = "dau-filter-group"
      filters {
        relative_dates_filter {
          filter_id = "dau-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Timestamp"
          }
          null_option = "NON_NULLS_ONLY"
          anchor_date_configuration {
            anchor_option = "NOW"
          }
          time_granularity    = "DAY"
          relative_date_type  = "LAST"
          relative_date_value = 1
          minimum_granularity = "DAY"
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-dau"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # CHAT_LOGS filter for MAU/WAU/DAU (these should only count chat messages)
    filter_groups {
      filter_group_id = "summary-chat-logtype-filter-group"
      filters {
        category_filter {
          filter_id = "summary-chat-logtype-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Log Type"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["CHAT_LOGS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-mau", "kpi-wau", "kpi-dau"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # --- Agent hours filters (scoped to agent hours visuals on Summary sheet) ---

    filter_groups {
      filter_group_id = "agent-hours-month-filter-group"
      filters {
        relative_dates_filter {
          filter_id = "agent-hours-month-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Timestamp"
          }
          null_option = "NON_NULLS_ONLY"
          anchor_date_configuration {
            anchor_option = "NOW"
          }
          time_granularity    = "DAY"
          relative_date_type  = "LAST"
          relative_date_value = 30
          minimum_granularity = "DAY"
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-professional-hours", "kpi-enterprise-hours", "kpi-additional-hours", "bar-hours-distribution", "line-additional-hours-trend"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    filter_groups {
      filter_group_id = "agent-hours-service-filter-group"
      filters {
        category_filter {
          filter_id = "agent-hours-service-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Reporting Service"
          }
          configuration {
            filter_list_configuration {
              match_operator     = "CONTAINS"
              category_values    = ["RESEARCH", "FLOW", "AUTOMATIONS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-professional-hours", "kpi-enterprise-hours", "kpi-additional-hours", "bar-hours-distribution", "line-additional-hours-trend"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    filter_groups {
      filter_group_id = "agent-hours-logtype-filter-group"
      filters {
        category_filter {
          filter_id = "agent-hours-logtype-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Log Type"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["AGENT_HOURS_LOGS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-professional-hours", "kpi-enterprise-hours", "kpi-additional-hours", "bar-hours-distribution", "line-additional-hours-trend"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # --- Queries & Conversations filters ---

    filter_groups {
      filter_group_id = "queries-date-filter-group"
      filters {
        relative_dates_filter {
          filter_id = "queries-date-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Timestamp"
          }
          null_option = "NON_NULLS_ONLY"
          anchor_date_configuration {
            anchor_option = "NOW"
          }
          time_granularity    = "DAY"
          relative_date_type  = "LAST"
          relative_date_value = 90
          minimum_granularity = "DAY"
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-total-conversations", "kpi-total-queries", "kpi-avg-queries-per-user", "kpi-avg-queries-per-conversation", "combo-conversations-queries-users", "bar-avg-queries-per-conversation", "bar-feedback-trend", "line-query-scope"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    filter_groups {
      filter_group_id = "queries-chat-logtype-filter-group"
      filters {
        category_filter {
          filter_id = "queries-chat-logtype-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Log Type"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["CHAT_LOGS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["kpi-total-conversations", "kpi-total-queries", "kpi-avg-queries-per-user", "kpi-avg-queries-per-conversation", "combo-conversations-queries-users", "bar-avg-queries-per-conversation", "line-query-scope"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    filter_groups {
      filter_group_id = "queries-feedback-logtype-filter-group"
      filters {
        category_filter {
          filter_id = "queries-feedback-logtype-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Log Type"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["FEEDBACK_LOGS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "summary"
            visual_ids = ["bar-feedback-trend"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # --- Asset Inventory filters (conditional) ---

    dynamic "filter_groups" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        filter_group_id = "asset-date-filter-group"
        filters {
          relative_dates_filter {
            filter_id = "asset-date-filter"
            column {
              data_set_identifier = "asset-inventory"
              column_name         = "Timestamp"
            }
            null_option = "NON_NULLS_ONLY"
            anchor_date_configuration {
              anchor_option = "NOW"
            }
            time_granularity    = "DAY"
            relative_date_type  = "LAST"
            relative_date_value = 90
            minimum_granularity = "DAY"
          }
        }
        scope_configuration {
          selected_sheets {
            sheet_visual_scoping_configurations {
              scope    = "ALL_VISUALS"
              sheet_id = "asset-inventory"
            }
          }
        }
        cross_dataset = "ALL_DATASETS"
        status        = "ENABLED"
      }
    }

    # Filter: upload visuals → only Document/Upload asset types
    dynamic "filter_groups" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        filter_group_id = "asset-upload-filter-group"
        filters {
          category_filter {
            filter_id = "asset-upload-filter"
            column {
              data_set_identifier = "asset-inventory"
              column_name         = "Asset Type"
            }
            configuration {
              filter_list_configuration {
                match_operator  = "CONTAINS"
                category_values = ["Document", "Upload"]
              }
            }
          }
        }
        scope_configuration {
          selected_sheets {
            sheet_visual_scoping_configurations {
              scope      = "SELECTED_VISUALS"
              sheet_id   = "asset-inventory"
              visual_ids = ["bar-top-uploaders", "line-upload-trend", "table-largest-uploads", "donut-uploads-by-type"]
            }
          }
        }
        cross_dataset = "ALL_DATASETS"
        status        = "ENABLED"
      }
    }

    # Filter: KB visuals → only Knowledge Base asset type
    dynamic "filter_groups" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        filter_group_id = "asset-kb-filter-group"
        filters {
          category_filter {
            filter_id = "asset-kb-filter"
            column {
              data_set_identifier = "asset-inventory"
              column_name         = "Asset Type"
            }
            configuration {
              filter_list_configuration {
                match_operator  = "CONTAINS"
                category_values = ["Knowledge Base"]
              }
            }
          }
        }
        scope_configuration {
          selected_sheets {
            sheet_visual_scoping_configurations {
              scope      = "SELECTED_VISUALS"
              sheet_id   = "asset-inventory"
              visual_ids = ["bar-kb-by-type"]
            }
          }
        }
        cross_dataset = "ALL_DATASETS"
        status        = "ENABLED"
      }
    }

    # Filter: creation visuals → only Create operations
    dynamic "filter_groups" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        filter_group_id = "asset-create-filter-group"
        filters {
          category_filter {
            filter_id = "asset-create-filter"
            column {
              data_set_identifier = "asset-inventory"
              column_name         = "Operation"
            }
            configuration {
              filter_list_configuration {
                match_operator  = "CONTAINS"
                category_values = ["Create"]
              }
            }
          }
        }
        scope_configuration {
          selected_sheets {
            sheet_visual_scoping_configurations {
              scope      = "SELECTED_VISUALS"
              sheet_id   = "asset-inventory"
              visual_ids = ["kpi-asset-spaces", "kpi-asset-kbs", "kpi-asset-flows", "kpi-asset-agents", "kpi-asset-documents", "area-asset-creation-trend", "donut-asset-type-breakdown", "bar-top-creators"]
            }
          }
        }
        cross_dataset = "ALL_DATASETS"
        status        = "ENABLED"
      }
    }

    # --- Dive Deep sheet filters ---

    # Date filter — user-configurable, scoped to all Dive Deep visuals
    filter_groups {
      filter_group_id = "dd-date-filter-group"
      filters {
        relative_dates_filter {
          filter_id = "dd-date-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Timestamp"
          }
          null_option = "NON_NULLS_ONLY"
          anchor_date_configuration {
            anchor_option = "NOW"
          }
          time_granularity    = "DAY"
          relative_date_type  = "LAST"
          relative_date_value = 90
          minimum_granularity = "DAY"
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope    = "ALL_VISUALS"
            sheet_id = "dive-deep"
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # Department filter — user-configurable, scoped to all Dive Deep visuals on messages dataset
    filter_groups {
      filter_group_id = "dd-department-filter-group"
      filters {
        category_filter {
          filter_id = "dd-department-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Department"
          }
          configuration {
            filter_list_configuration {
              match_operator       = "CONTAINS"
              select_all_options   = "FILTER_ALL_VALUES"
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope    = "ALL_VISUALS"
            sheet_id = "dive-deep"
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # Country filter — user-configurable, scoped to all Dive Deep visuals on messages dataset
    filter_groups {
      filter_group_id = "dd-country-filter-group"
      filters {
        category_filter {
          filter_id = "dd-country-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Country"
          }
          configuration {
            filter_list_configuration {
              match_operator       = "CONTAINS"
              select_all_options   = "FILTER_ALL_VALUES"
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope    = "ALL_VISUALS"
            sheet_id = "dive-deep"
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # CHAT_LOGS fixed filter — scoped to chat-based visuals
    filter_groups {
      filter_group_id = "dd-chat-logtype-filter-group"
      filters {
        category_filter {
          filter_id = "dd-chat-logtype-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Log Type"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["CHAT_LOGS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "dive-deep"
            visual_ids = ["dd-kpi-active-users", "dd-kpi-stickiness", "dd-kpi-active-pct", "dd-bar-top-users", "dd-bar-by-department", "dd-bar-by-country", "dd-table-user-activity", "dd-donut-tier", "dd-donut-status", "dd-line-blocked", "dd-bar-by-agent", "dd-bar-hour", "dd-bar-day-of-week", "dd-line-daily-volume"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # FEEDBACK_LOGS fixed filter — scoped to feedback visuals
    filter_groups {
      filter_group_id = "dd-feedback-logtype-filter-group"
      filters {
        category_filter {
          filter_id = "dd-feedback-logtype-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Log Type"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["FEEDBACK_LOGS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "dive-deep"
            visual_ids = ["dd-kpi-feedback-rate", "dd-table-feedback-users"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # AGENT_HOURS_LOGS fixed filter — scoped to agent hours table
    filter_groups {
      filter_group_id = "dd-agenthours-logtype-filter-group"
      filters {
        category_filter {
          filter_id = "dd-agenthours-logtype-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Log Type"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["AGENT_HOURS_LOGS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "dive-deep"
            visual_ids = ["dd-table-agent-hours"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # --- Categorization sheet filters ---

    # Date filter — user-configurable, LAST 90 days default, scoped to all Categorization visuals
    filter_groups {
      filter_group_id = "cat-date-filter-group"
      filters {
        relative_dates_filter {
          filter_id = "cat-date-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Timestamp"
          }
          null_option = "NON_NULLS_ONLY"
          anchor_date_configuration {
            anchor_option = "NOW"
          }
          time_granularity    = "DAY"
          relative_date_type  = "LAST"
          relative_date_value = 90
          minimum_granularity = "DAY"
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope    = "ALL_VISUALS"
            sheet_id = "categorization"
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # CHAT_LOGS fixed filter — scoped to all categorization visuals
    filter_groups {
      filter_group_id = "cat-logtype-filter-group"
      filters {
        category_filter {
          filter_id = "cat-logtype-filter"
          column {
            data_set_identifier = "messages"
            column_name         = "Log Type"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["CHAT_LOGS"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope    = "ALL_VISUALS"
            sheet_id = "categorization"
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # Exclude Uncategorized fixed filter — scoped to all categorization visuals
    filter_groups {
      filter_group_id = "cat-exclude-uncategorized-filter-group"
      filters {
        category_filter {
          filter_id = "cat-exclude-uncategorized"
          column {
            data_set_identifier = "messages"
            column_name         = "Prompt Category"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "DOES_NOT_CONTAIN"
              category_values = ["Uncategorized"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope    = "ALL_VISUALS"
            sheet_id = "categorization"
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # --- SPICE & Data Health sheet filters ---

    # Filter: failed ingestions table → only FAILED status
    filter_groups {
      filter_group_id = "health-failed-filter-group"
      filters {
        category_filter {
          filter_id = "health-failed-filter"
          column {
            data_set_identifier = "dataset-health"
            column_name         = "Ingestion Status"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["FAILED"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "spice-health"
            visual_ids = ["health-failed-table"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # Filter: top SPICE datasets → only SPICE import mode
    filter_groups {
      filter_group_id = "health-spice-mode-filter-group"
      filters {
        category_filter {
          filter_id = "health-spice-mode-filter"
          column {
            data_set_identifier = "dataset-health"
            column_name         = "Import Mode"
          }
          configuration {
            filter_list_configuration {
              match_operator  = "CONTAINS"
              category_values = ["SPICE"]
            }
          }
        }
      }
      scope_configuration {
        selected_sheets {
          sheet_visual_scoping_configurations {
            scope      = "SELECTED_VISUALS"
            sheet_id   = "spice-health"
            visual_ids = ["health-top-spice"]
          }
        }
      }
      cross_dataset = "ALL_DATASETS"
      status        = "ENABLED"
    }

    # --- BI Assets section filters (on asset-inventory sheet) ---

    # Filter: dashboard-dataset table → only Dashboard asset type
    dynamic "filter_groups" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        filter_group_id = "bi-dashboard-filter-group"
        filters {
          category_filter {
            filter_id = "bi-dashboard-filter"
            column {
              data_set_identifier = "bi-assets"
              column_name         = "Asset Type"
            }
            configuration {
              filter_list_configuration {
                match_operator  = "CONTAINS"
                category_values = ["Dashboard"]
              }
            }
          }
        }
        scope_configuration {
          selected_sheets {
            sheet_visual_scoping_configurations {
              scope      = "SELECTED_VISUALS"
              sheet_id   = "asset-inventory"
              visual_ids = ["bi-total-dashboards", "bi-dashboard-dataset-table"]
            }
          }
        }
        cross_dataset = "ALL_DATASETS"
        status        = "ENABLED"
      }
    }

    # Filter: analysis visuals → only Analysis asset type
    dynamic "filter_groups" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        filter_group_id = "bi-analysis-filter-group"
        filters {
          category_filter {
            filter_id = "bi-analysis-filter"
            column {
              data_set_identifier = "bi-assets"
              column_name         = "Asset Type"
            }
            configuration {
              filter_list_configuration {
                match_operator  = "CONTAINS"
                category_values = ["Analysis"]
              }
            }
          }
        }
        scope_configuration {
          selected_sheets {
            sheet_visual_scoping_configurations {
              scope      = "SELECTED_VISUALS"
              sheet_id   = "asset-inventory"
              visual_ids = ["bi-total-analyses", "bi-analysis-status"]
            }
          }
        }
        cross_dataset = "ALL_DATASETS"
        status        = "ENABLED"
      }
    }

    # Filter: datasource visuals → only Datasource asset type
    dynamic "filter_groups" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        filter_group_id = "bi-datasource-filter-group"
        filters {
          category_filter {
            filter_id = "bi-datasource-filter"
            column {
              data_set_identifier = "bi-assets"
              column_name         = "Asset Type"
            }
            configuration {
              filter_list_configuration {
                match_operator  = "CONTAINS"
                category_values = ["Datasource"]
              }
            }
          }
        }
        scope_configuration {
          selected_sheets {
            sheet_visual_scoping_configurations {
              scope      = "SELECTED_VISUALS"
              sheet_id   = "asset-inventory"
              visual_ids = ["bi-total-datasources", "bi-dataset-datasource-table", "bi-datasource-types"]
            }
          }
        }
        cross_dataset = "ALL_DATASETS"
        status        = "ENABLED"
      }
    }

    # Filter: orphaned datasets → only Is Orphaned = Yes
    dynamic "filter_groups" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        filter_group_id = "bi-orphaned-filter-group"
        filters {
          category_filter {
            filter_id = "bi-orphaned-filter"
            column {
              data_set_identifier = "dataset-health"
              column_name         = "Is Orphaned"
            }
            configuration {
              filter_list_configuration {
                match_operator  = "CONTAINS"
                category_values = ["Yes"]
              }
            }
          }
        }
        scope_configuration {
          selected_sheets {
            sheet_visual_scoping_configurations {
              scope      = "SELECTED_VISUALS"
              sheet_id   = "asset-inventory"
              visual_ids = ["bi-orphaned-datasets"]
            }
          }
        }
        cross_dataset = "ALL_DATASETS"
        status        = "ENABLED"
      }
    }

    # ==================== Sheet 1: Summary (default) ====================

    sheets {
      sheet_id = "summary"
      name     = "Summary"

      sheet_control_layouts {
        configuration {
          grid_layout {
            elements {
              element_type = "FILTER_CONTROL"
              element_id   = "agent-hours-month-picker"
              column_span  = 4
              row_span     = 1
            }
            elements {
              element_type = "FILTER_CONTROL"
              element_id   = "agent-hours-service-picker"
              column_span  = 4
              row_span     = 1
            }
            elements {
              element_type = "FILTER_CONTROL"
              element_id   = "queries-date-picker"
              column_span  = 4
              row_span     = 1
            }
          }
        }
      }

      filter_controls {
        relative_date_time {
          filter_control_id = "agent-hours-month-picker"
          title             = "Month"
          source_filter_id  = "agent-hours-month-filter"
        }
      }

      filter_controls {
        dropdown {
          filter_control_id = "agent-hours-service-picker"
          title             = "Reporting Service"
          source_filter_id  = "agent-hours-service-filter"
          type              = "MULTI_SELECT"
        }
      }

      filter_controls {
        relative_date_time {
          filter_control_id = "queries-date-picker"
          title             = "Queries Date Range"
          source_filter_id  = "queries-date-filter"
        }
      }

      layouts {
        configuration {
          grid_layout {
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-mau"
              column_index = 0
              row_index    = 0
              column_span  = 12
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-wau"
              column_index = 12
              row_index    = 0
              column_span  = 12
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-dau"
              column_index = 24
              row_index    = 0
              column_span  = 12
              row_span     = 8
            }
            # Row 9-15: Queries KPIs
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-total-conversations"
              column_index = 0
              row_index    = 9
              column_span  = 9
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-total-queries"
              column_index = 9
              row_index    = 9
              column_span  = 9
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-avg-queries-per-user"
              column_index = 18
              row_index    = 9
              column_span  = 9
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-avg-queries-per-conversation"
              column_index = 27
              row_index    = 9
              column_span  = 9
              row_span     = 7
            }
            # Row 16-23: combo chart + avg queries bar
            elements {
              element_type = "VISUAL"
              element_id   = "combo-conversations-queries-users"
              column_index = 0
              row_index    = 16
              column_span  = 18
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "bar-avg-queries-per-conversation"
              column_index = 18
              row_index    = 16
              column_span  = 18
              row_span     = 8
            }
            # Row 24-31: feedback trend + query scope line
            elements {
              element_type = "VISUAL"
              element_id   = "bar-feedback-trend"
              column_index = 0
              row_index    = 24
              column_span  = 18
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "line-query-scope"
              column_index = 18
              row_index    = 24
              column_span  = 18
              row_span     = 8
            }
            # Row 32-38: Agent hours KPIs
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-professional-hours"
              column_index = 0
              row_index    = 32
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-enterprise-hours"
              column_index = 12
              row_index    = 32
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "kpi-additional-hours"
              column_index = 24
              row_index    = 32
              column_span  = 12
              row_span     = 7
            }
            # Row 39-46: Agent hours charts
            elements {
              element_type = "VISUAL"
              element_id   = "bar-hours-distribution"
              column_index = 0
              row_index    = 39
              column_span  = 18
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "line-additional-hours-trend"
              column_index = 18
              row_index    = 39
              column_span  = 18
              row_span     = 8
            }
            canvas_size_options {
              screen_canvas_size_options {
                resize_option             = "FIXED"
                optimized_view_port_width = "1600px"
              }
            }
          }
        }
      }

      # KPI: Trending this month (MAU)
      visuals {
        kpi_visual {
          visual_id = "kpi-mau"
          title {
            format_text {
              rich_text = local.kpi_title.mau
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.mau
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "mau-messages"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Message Count"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "mau-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "mau-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Trending this week (WAU)
      visuals {
        kpi_visual {
          visual_id = "kpi-wau"
          title {
            format_text {
              rich_text = local.kpi_title.wau
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.wau
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "wau-messages"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Message Count"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "wau-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "wau-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Trending today (DAU)
      visuals {
        kpi_visual {
          visual_id = "kpi-dau"
          title {
            format_text {
              rich_text = local.kpi_title.dau
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.dau
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "dau-messages"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Message Count"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "dau-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "HOUR"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "dau-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Professional Hours
      visuals {
        kpi_visual {
          visual_id = "kpi-professional-hours"
          title {
            format_text {
              rich_text = local.kpi_title.professional_hours
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.professional_hours
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "professional-hours-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Usage Hours"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "professional-hours-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "professional-hours-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Enterprise Hours
      visuals {
        kpi_visual {
          visual_id = "kpi-enterprise-hours"
          title {
            format_text {
              rich_text = local.kpi_title.enterprise_hours
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.enterprise_hours
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "enterprise-hours-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Usage Hours"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "enterprise-hours-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "enterprise-hours-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Additional Hours (Usage Group = Extra)
      visuals {
        kpi_visual {
          visual_id = "kpi-additional-hours"
          title {
            format_text {
              rich_text = local.kpi_title.additional_hours
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.additional_hours
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "additional-hours-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Usage Hours"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "additional-hours-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "additional-hours-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # Bar chart: Hours distribution by subscription type
      # Uses dataset-level sumOver/maxOver calculated fields (Pct Consumed, Allotment Bucket)
      visuals {
        bar_chart_visual {
          visual_id = "bar-hours-distribution"
          title {
            format_text {
              rich_text = local.kpi_title.hours_distribution
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.hours_distribution
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "allotment-bucket"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Allotment Bucket"
                    }
                  }
                }
                values {
                  categorical_measure_field {
                    field_id = "user-count"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Username"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                    format_configuration {
                      numeric_format_configuration {
                        number_display_format_configuration {
                          decimal_places_configuration {
                            decimal_places = 0
                          }
                        }
                      }
                    }
                  }
                }
                colors {
                  categorical_dimension_field {
                    field_id = "license-color"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "License Type"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "allotment-bucket"
                  direction = "ASC"
                }
              }
            }
            orientation = "VERTICAL"
          }
        }
      }

      # Line chart: Additional hours by week
      visuals {
        line_chart_visual {
          visual_id = "line-additional-hours-trend"
          title {
            format_text {
              rich_text = local.kpi_title.additional_hours_trend
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.additional_hours_trend
            }
          }
          chart_configuration {
            field_wells {
              line_chart_aggregated_field_wells {
                category {
                  date_dimension_field {
                    field_id = "trend-week"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "WEEK"
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "trend-hours"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Usage Hours"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "trend-week"
                  direction = "ASC"
                }
              }
            }
            type = "LINE"
          }
        }
      }
      # KPI: Total Conversations
      visuals {
        kpi_visual {
          visual_id = "kpi-total-conversations"
          title {
            format_text {
              rich_text = local.kpi_title.total_conversations
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.total_conversations
            }
          }
          chart_configuration {
            field_wells {
              values {
                categorical_measure_field {
                  field_id = "total-conversations-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Conversation"
                  }
                  aggregation_function = "DISTINCT_COUNT"
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "total-conversations-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "total-conversations-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Total Queries
      visuals {
        kpi_visual {
          visual_id = "kpi-total-queries"
          title {
            format_text {
              rich_text = local.kpi_title.total_queries
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.total_queries
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "total-queries-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Message Count"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "total-queries-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "total-queries-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Avg Queries per User
      visuals {
        kpi_visual {
          visual_id = "kpi-avg-queries-per-user"
          title {
            format_text {
              rich_text = local.kpi_title.avg_queries_per_user
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.avg_queries_per_user
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "avg-queries-per-user-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Avg Queries Per User"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "AVERAGE"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "avg-queries-per-user-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "avg-queries-per-user-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Avg Queries per Conversation
      visuals {
        kpi_visual {
          visual_id = "kpi-avg-queries-per-conversation"
          title {
            format_text {
              rich_text = local.kpi_title.avg_queries_per_conversation
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.avg_queries_per_conversation
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "avg-queries-per-conv-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Avg Queries Per Conversation"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "AVERAGE"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "avg-queries-per-conv-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "avg-queries-per-conv-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # Combo chart: Conversations, Queries & Active Users
      visuals {
        combo_chart_visual {
          visual_id = "combo-conversations-queries-users"
          title {
            format_text {
              rich_text = local.kpi_title.conversations_queries_users
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.conversations_queries_users
            }
          }
          chart_configuration {
            field_wells {
              combo_chart_aggregated_field_wells {
                category {
                  date_dimension_field {
                    field_id = "combo-category-month"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "MONTH"
                  }
                }
                bar_values {
                  categorical_measure_field {
                    field_id = "combo-bar-conversations"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Conversation"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
                bar_values {
                  numerical_measure_field {
                    field_id = "combo-bar-queries"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                line_values {
                  categorical_measure_field {
                    field_id = "combo-line-users"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Username"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "combo-category-month"
                  direction = "ASC"
                }
              }
            }
            bars_arrangement = "CLUSTERED"
          }
        }
      }

      # Bar chart: Avg Queries per Conversation
      visuals {
        bar_chart_visual {
          visual_id = "bar-avg-queries-per-conversation"
          title {
            format_text {
              rich_text = local.kpi_title.avg_queries_chart
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.avg_queries_chart
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  date_dimension_field {
                    field_id = "avg-queries-chart-month"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "MONTH"
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "avg-queries-chart-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "avg-queries-chart-month"
                  direction = "ASC"
                }
              }
            }
            orientation = "VERTICAL"
          }
        }
      }

      # Stacked bar chart: Customer Feedback Trend
      visuals {
        bar_chart_visual {
          visual_id = "bar-feedback-trend"
          title {
            format_text {
              rich_text = local.kpi_title.feedback_trend
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.feedback_trend
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  date_dimension_field {
                    field_id = "feedback-trend-month"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "MONTH"
                  }
                }
                values {
                  categorical_measure_field {
                    field_id = "feedback-trend-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Feedback Type"
                    }
                    aggregation_function = "COUNT"
                  }
                }
                colors {
                  categorical_dimension_field {
                    field_id = "feedback-trend-color"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Feedback Type"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "feedback-trend-month"
                  direction = "ASC"
                }
              }
            }
            orientation  = "VERTICAL"
            bars_arrangement = "STACKED"
          }
        }
      }

      # Line chart: Query Scope Selection
      visuals {
        line_chart_visual {
          visual_id = "line-query-scope"
          title {
            format_text {
              rich_text = local.kpi_title.query_scope_chart
            }
          }
          subtitle {
            format_text {
              rich_text = local.kpi_subtitle.query_scope_chart
            }
          }
          chart_configuration {
            field_wells {
              line_chart_aggregated_field_wells {
                category {
                  date_dimension_field {
                    field_id = "query-scope-month"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "MONTH"
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "query-scope-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                colors {
                  categorical_dimension_field {
                    field_id = "query-scope-color"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Query Scope"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "query-scope-month"
                  direction = "ASC"
                }
              }
            }
            type = "LINE"
          }
        }
      }
    }

    # ==================== Sheet 2: Dive Deep ====================

    sheets {
      sheet_id = "dive-deep"
      name     = "Dive Deep"

      # Filter controls bar at top
      sheet_control_layouts {
        configuration {
          grid_layout {
            elements {
              element_type = "FILTER_CONTROL"
              element_id   = "dd-date-picker"
              column_span  = 4
              row_span     = 1
            }
            elements {
              element_type = "FILTER_CONTROL"
              element_id   = "dd-department-picker"
              column_span  = 4
              row_span     = 1
            }
            elements {
              element_type = "FILTER_CONTROL"
              element_id   = "dd-country-picker"
              column_span  = 4
              row_span     = 1
            }
          }
        }
      }

      filter_controls {
        relative_date_time {
          filter_control_id = "dd-date-picker"
          title             = "Date Range"
          source_filter_id  = "dd-date-filter"
        }
      }

      filter_controls {
        dropdown {
          filter_control_id = "dd-department-picker"
          title             = "Department"
          source_filter_id  = "dd-department-filter"
          type              = "MULTI_SELECT"
        }
      }

      filter_controls {
        dropdown {
          filter_control_id = "dd-country-picker"
          title             = "Country"
          source_filter_id  = "dd-country-filter"
          type              = "MULTI_SELECT"
        }
      }

      layouts {
        configuration {
          grid_layout {
            # === Section 1: User Activity ===
            # Row 1-7: 3 KPIs
            elements {
              element_type = "VISUAL"
              element_id   = "dd-kpi-active-users"
              column_index = 0
              row_index    = 1
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-kpi-stickiness"
              column_index = 12
              row_index    = 1
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-kpi-active-pct"
              column_index = 24
              row_index    = 1
              column_span  = 12
              row_span     = 7
            }
            # Row 8-15: Top Users bar + Activity by Department bar
            elements {
              element_type = "VISUAL"
              element_id   = "dd-bar-top-users"
              column_index = 0
              row_index    = 8
              column_span  = 18
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-bar-by-department"
              column_index = 18
              row_index    = 8
              column_span  = 18
              row_span     = 8
            }
            # Row 16-23: Activity by Country bar + User Activity Table
            elements {
              element_type = "VISUAL"
              element_id   = "dd-bar-by-country"
              column_index = 0
              row_index    = 16
              column_span  = 18
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-table-user-activity"
              column_index = 18
              row_index    = 16
              column_span  = 18
              row_span     = 8
            }
            # === Section 2: Engagement & Quality ===
            # Row 24-30: Tier donut + Status donut + Blocked trend line
            elements {
              element_type = "VISUAL"
              element_id   = "dd-donut-tier"
              column_index = 0
              row_index    = 24
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-donut-status"
              column_index = 12
              row_index    = 24
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-line-blocked"
              column_index = 24
              row_index    = 24
              column_span  = 12
              row_span     = 7
            }
            # Row 31-38: Messages by Agent bar + Plugin Utilization bar
            elements {
              element_type = "VISUAL"
              element_id   = "dd-bar-by-agent"
              column_index = 0
              row_index    = 31
              column_span  = 18
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-bar-plugins"
              column_index = 18
              row_index    = 31
              column_span  = 18
              row_span     = 8
            }
            # === Section 3: Usage Patterns ===
            # Row 39-45: Hour of Day bar + Day of Week bar
            elements {
              element_type = "VISUAL"
              element_id   = "dd-bar-hour"
              column_index = 0
              row_index    = 39
              column_span  = 18
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-bar-day-of-week"
              column_index = 18
              row_index    = 39
              column_span  = 18
              row_span     = 7
            }
            # Row 46-53: Daily Volume line (full width)
            elements {
              element_type = "VISUAL"
              element_id   = "dd-line-daily-volume"
              column_index = 0
              row_index    = 46
              column_span  = 36
              row_span     = 8
            }
            # === Section 4: Resource & Feedback ===
            # Row 54-60: Feedback Rate KPI + Top Resources horiz bar
            elements {
              element_type = "VISUAL"
              element_id   = "dd-kpi-feedback-rate"
              column_index = 0
              row_index    = 54
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-bar-top-resources"
              column_index = 12
              row_index    = 54
              column_span  = 24
              row_span     = 7
            }
            # Row 61-68: Top 10 Feedback Users table + Resource Type donut
            elements {
              element_type = "VISUAL"
              element_id   = "dd-table-feedback-users"
              column_index = 0
              row_index    = 61
              column_span  = 18
              row_span     = 8
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-donut-resource-type"
              column_index = 18
              row_index    = 61
              column_span  = 18
              row_span     = 8
            }
            # === Section 5: License & Cost ===
            # Row 69-75: Unused License KPIs
            elements {
              element_type = "VISUAL"
              element_id   = "dd-kpi-unused-total"
              column_index = 0
              row_index    = 69
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-kpi-unused-pro"
              column_index = 12
              row_index    = 69
              column_span  = 12
              row_span     = 7
            }
            elements {
              element_type = "VISUAL"
              element_id   = "dd-kpi-unused-enterprise"
              column_index = 24
              row_index    = 69
              column_span  = 12
              row_span     = 7
            }
            # Row 76-83: Top 10 Agent Hours table (full width)
            elements {
              element_type = "VISUAL"
              element_id   = "dd-table-agent-hours"
              column_index = 0
              row_index    = 76
              column_span  = 36
              row_span     = 8
            }
            canvas_size_options {
              screen_canvas_size_options {
                resize_option             = "FIXED"
                optimized_view_port_width = "1600px"
              }
            }
          }
        }
      }

      # === Section 1: User Activity Visuals ===

      # KPI: Active Users
      visuals {
        kpi_visual {
          visual_id = "dd-kpi-active-users"
          title {
            format_text {
              rich_text = local.dd_kpi_title.active_users
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_kpi_subtitle.active_users
            }
          }
          chart_configuration {
            field_wells {
              values {
                categorical_measure_field {
                  field_id = "dd-active-users-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Username"
                  }
                  aggregation_function = "DISTINCT_COUNT"
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "dd-active-users-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "dd-active-users-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Stickiness Ratio (DAU/MAU approximation — message count SUM)
      visuals {
        kpi_visual {
          visual_id = "dd-kpi-stickiness"
          title {
            format_text {
              rich_text = local.dd_kpi_title.stickiness
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_kpi_subtitle.stickiness
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "dd-stickiness-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Message Count"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "dd-stickiness-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "dd-stickiness-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Active AI Users %
      visuals {
        kpi_visual {
          visual_id = "dd-kpi-active-pct"
          title {
            format_text {
              rich_text = local.dd_kpi_title.active_pct
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_kpi_subtitle.active_pct
            }
          }
          chart_configuration {
            field_wells {
              values {
                categorical_measure_field {
                  field_id = "dd-active-pct-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Username"
                  }
                  aggregation_function = "DISTINCT_COUNT"
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "dd-active-pct-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "dd-active-pct-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # Bar: Top 20 Users (horizontal)
      visuals {
        bar_chart_visual {
          visual_id = "dd-bar-top-users"
          title {
            format_text {
              rich_text = local.dd_chart_title.top_users
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.top_users
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-top-users-category"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Username"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-top-users-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-top-users-value"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 20
                other_categories = "INCLUDE"
              }
              color_items_limit {
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 1
                other_categories = "INCLUDE"
              }
            }
            orientation = "HORIZONTAL"
          }
        }
      }

      # Bar: Activity by Department (vertical)
      visuals {
        bar_chart_visual {
          visual_id = "dd-bar-by-department"
          title {
            format_text {
              rich_text = local.dd_chart_title.by_department
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.by_department
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-by-dept-category"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Department"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-by-dept-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-by-dept-value"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 20
                other_categories = "INCLUDE"
              }
              color_items_limit {
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 1
                other_categories = "INCLUDE"
              }
            }
            orientation = "VERTICAL"
          }
        }
      }

      # Bar: Activity by Country (vertical)
      visuals {
        bar_chart_visual {
          visual_id = "dd-bar-by-country"
          title {
            format_text {
              rich_text = local.dd_chart_title.by_country
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.by_country
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-by-country-category"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Country"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-by-country-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-by-country-value"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 20
                other_categories = "INCLUDE"
              }
              color_items_limit {
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 1
                other_categories = "INCLUDE"
              }
            }
            orientation = "VERTICAL"
          }
        }
      }

      # Table: User Activity
      visuals {
        table_visual {
          visual_id = "dd-table-user-activity"
          title {
            format_text {
              rich_text = local.dd_chart_title.user_activity_table
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.user_activity_table
            }
          }
          chart_configuration {
            field_wells {
              table_aggregated_field_wells {
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-user-activity-username"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Username"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-user-activity-name"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Name"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-user-activity-department"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Department"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-user-activity-license"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "License Type"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-user-activity-messages"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                values {
                  categorical_measure_field {
                    field_id = "dd-user-activity-convs"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Conversation"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
              }
            }
            sort_configuration {
              row_sort {
                field_sort {
                  field_id  = "dd-user-activity-messages"
                  direction = "DESC"
                }
              }
            }
          }
        }
      }

      # === Section 2: Engagement & Quality Visuals ===

      # Donut: User Tier Breakdown
      visuals {
        pie_chart_visual {
          visual_id = "dd-donut-tier"
          title {
            format_text {
              rich_text = local.dd_chart_title.tier_breakdown
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.tier_breakdown
            }
          }
          chart_configuration {
            field_wells {
              pie_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-donut-tier-group"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "User Tier"
                    }
                  }
                }
                values {
                  categorical_measure_field {
                    field_id = "dd-donut-tier-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Username"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
              }
            }
            donut_options {
              arc_options {
                arc_thickness = "WHOLE"
              }
            }
          }
        }
      }

      # Donut: Status Distribution
      visuals {
        pie_chart_visual {
          visual_id = "dd-donut-status"
          title {
            format_text {
              rich_text = local.dd_chart_title.status_dist
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.status_dist
            }
          }
          chart_configuration {
            field_wells {
              pie_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-donut-status-group"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Status"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-donut-status-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            donut_options {
              arc_options {
                arc_thickness = "WHOLE"
              }
            }
          }
        }
      }

      # Line: Blocked Requests Trend
      visuals {
        line_chart_visual {
          visual_id = "dd-line-blocked"
          title {
            format_text {
              rich_text = local.dd_chart_title.blocked_trend
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.blocked_trend
            }
          }
          chart_configuration {
            field_wells {
              line_chart_aggregated_field_wells {
                category {
                  date_dimension_field {
                    field_id = "dd-blocked-month"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "MONTH"
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-blocked-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-blocked-month"
                  direction = "ASC"
                }
              }
            }
            type = "LINE"
          }
        }
      }

      # Bar: Messages by Agent (vertical)
      visuals {
        bar_chart_visual {
          visual_id = "dd-bar-by-agent"
          title {
            format_text {
              rich_text = local.dd_chart_title.by_agent
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.by_agent
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-by-agent-category"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Agent Label"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-by-agent-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-by-agent-value"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 20
                other_categories = "INCLUDE"
              }
              color_items_limit {
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 1
                other_categories = "INCLUDE"
              }
            }
            orientation = "VERTICAL"
          }
        }
      }

      # Bar: Plugin Utilization (horizontal, plugin-utilization dataset)
      visuals {
        bar_chart_visual {
          visual_id = "dd-bar-plugins"
          title {
            format_text {
              rich_text = local.dd_chart_title.plugins
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.plugins
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-plugins-category"
                    column {
                      data_set_identifier = "plugin-utilization"
                      column_name         = "Plugin"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-plugins-value"
                    column {
                      data_set_identifier = "plugin-utilization"
                      column_name         = "Plugin Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-plugins-value"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 20
                other_categories = "INCLUDE"
              }
              color_items_limit {
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 1
                other_categories = "INCLUDE"
              }
            }
            orientation = "HORIZONTAL"
          }
        }
      }

      # === Section 3: Usage Patterns Visuals ===

      # Bar: Messages by Hour of Day (vertical)
      visuals {
        bar_chart_visual {
          visual_id = "dd-bar-hour"
          title {
            format_text {
              rich_text = local.dd_chart_title.hour_of_day
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.hour_of_day
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  numerical_dimension_field {
                    field_id = "dd-hour-category"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Hour of Day"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-hour-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-hour-category"
                  direction = "ASC"
                }
              }
            }
            orientation = "VERTICAL"
          }
        }
      }

      # Bar: Messages by Day of Week (vertical)
      visuals {
        bar_chart_visual {
          visual_id = "dd-bar-day-of-week"
          title {
            format_text {
              rich_text = local.dd_chart_title.day_of_week
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.day_of_week
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-dow-category"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Day of Week Label"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-dow-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-dow-value"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 7
                other_categories = "INCLUDE"
              }
              color_items_limit {
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 1
                other_categories = "INCLUDE"
              }
            }
            orientation = "VERTICAL"
          }
        }
      }

      # Line: Daily Message Volume
      visuals {
        line_chart_visual {
          visual_id = "dd-line-daily-volume"
          title {
            format_text {
              rich_text = local.dd_chart_title.daily_volume
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.daily_volume
            }
          }
          chart_configuration {
            field_wells {
              line_chart_aggregated_field_wells {
                category {
                  date_dimension_field {
                    field_id = "dd-daily-vol-day"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "DAY"
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-daily-vol-value"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-daily-vol-day"
                  direction = "ASC"
                }
              }
            }
            type = "LINE"
          }
        }
      }

      # === Section 4: Resource & Feedback Visuals ===

      # KPI: Feedback Rate (count)
      visuals {
        kpi_visual {
          visual_id = "dd-kpi-feedback-rate"
          title {
            format_text {
              rich_text = local.dd_kpi_title.feedback_rate
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_kpi_subtitle.feedback_rate
            }
          }
          chart_configuration {
            field_wells {
              values {
                numerical_measure_field {
                  field_id = "dd-feedback-rate-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Message Count"
                  }
                  aggregation_function {
                    simple_numerical_aggregation = "SUM"
                  }
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "dd-feedback-rate-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "dd-feedback-rate-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # Bar: Top Resources Queried (horizontal, resource-selections dataset)
      visuals {
        bar_chart_visual {
          visual_id = "dd-bar-top-resources"
          title {
            format_text {
              rich_text = local.dd_chart_title.top_resources
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.top_resources
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-top-resources-category"
                    column {
                      data_set_identifier = "resource-selections"
                      column_name         = "Resource ID"
                    }
                  }
                }
                values {
                  categorical_measure_field {
                    field_id = "dd-top-resources-value"
                    column {
                      data_set_identifier = "resource-selections"
                      column_name         = "Conversation"
                    }
                    aggregation_function = "COUNT"
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "dd-top-resources-value"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 10
                other_categories = "INCLUDE"
              }
              color_items_limit {
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 1
                other_categories = "INCLUDE"
              }
            }
            orientation = "HORIZONTAL"
          }
        }
      }

      # Table: Top 10 Feedback Users
      visuals {
        table_visual {
          visual_id = "dd-table-feedback-users"
          title {
            format_text {
              rich_text = local.dd_chart_title.feedback_users
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.feedback_users
            }
          }
          chart_configuration {
            field_wells {
              table_aggregated_field_wells {
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-feedback-users-username"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Username"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-feedback-users-name"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Name"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-feedback-users-count"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              row_sort {
                field_sort {
                  field_id  = "dd-feedback-users-count"
                  direction = "DESC"
                }
              }
            }
          }
        }
      }

      # Donut: Resource Type Distribution (resource-selections dataset)
      visuals {
        pie_chart_visual {
          visual_id = "dd-donut-resource-type"
          title {
            format_text {
              rich_text = local.dd_chart_title.resource_type
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.resource_type
            }
          }
          chart_configuration {
            field_wells {
              pie_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "dd-resource-type-group"
                    column {
                      data_set_identifier = "resource-selections"
                      column_name         = "Resource Type"
                    }
                  }
                }
                values {
                  categorical_measure_field {
                    field_id = "dd-resource-type-value"
                    column {
                      data_set_identifier = "resource-selections"
                      column_name         = "Conversation"
                    }
                    aggregation_function = "COUNT"
                  }
                }
              }
            }
            donut_options {
              arc_options {
                arc_thickness = "WHOLE"
              }
            }
          }
        }
      }

      # === Section 5: License & Cost Visuals ===

      # KPI: Unused Licenses (Total) — users with tier in Never Active/Dormant/Churned
      visuals {
        kpi_visual {
          visual_id = "dd-kpi-unused-total"
          title {
            format_text {
              rich_text = local.dd_kpi_title.unused_total
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_kpi_subtitle.unused_total
            }
          }
          chart_configuration {
            field_wells {
              values {
                categorical_measure_field {
                  field_id = "dd-unused-total-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Username"
                  }
                  aggregation_function = "DISTINCT_COUNT"
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "dd-unused-total-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "dd-unused-total-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Unused Licenses (Professional)
      visuals {
        kpi_visual {
          visual_id = "dd-kpi-unused-pro"
          title {
            format_text {
              rich_text = local.dd_kpi_title.unused_pro
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_kpi_subtitle.unused_pro
            }
          }
          chart_configuration {
            field_wells {
              values {
                categorical_measure_field {
                  field_id = "dd-unused-pro-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Username"
                  }
                  aggregation_function = "DISTINCT_COUNT"
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "dd-unused-pro-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "dd-unused-pro-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # KPI: Unused Licenses (Enterprise)
      visuals {
        kpi_visual {
          visual_id = "dd-kpi-unused-enterprise"
          title {
            format_text {
              rich_text = local.dd_kpi_title.unused_enterprise
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_kpi_subtitle.unused_enterprise
            }
          }
          chart_configuration {
            field_wells {
              values {
                categorical_measure_field {
                  field_id = "dd-unused-enterprise-value"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Username"
                  }
                  aggregation_function = "DISTINCT_COUNT"
                }
              }
              trend_groups {
                date_dimension_field {
                  field_id = "dd-unused-enterprise-trend"
                  column {
                    data_set_identifier = "messages"
                    column_name         = "Timestamp"
                  }
                  date_granularity = "DAY"
                }
              }
            }
            sort_configuration {
              trend_group_sort {
                field_sort {
                  field_id  = "dd-unused-enterprise-trend"
                  direction = "ASC"
                }
              }
            }
            kpi_options {
              trend_arrows {
                visibility = "VISIBLE"
              }
              sparkline {
                visibility         = "VISIBLE"
                type               = "LINE"
                tooltip_visibility = "VISIBLE"
              }
              primary_value_display_type = "ACTUAL"
            }
          }
        }
      }

      # Table: Top 10 Agent Hours by User
      visuals {
        table_visual {
          visual_id = "dd-table-agent-hours"
          title {
            format_text {
              rich_text = local.dd_chart_title.agent_hours_table
            }
          }
          subtitle {
            format_text {
              rich_text = local.dd_chart_subtitle.agent_hours_table
            }
          }
          chart_configuration {
            field_wells {
              table_aggregated_field_wells {
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-agent-hours-username"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Username"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-agent-hours-name"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Name"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "dd-agent-hours-license"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "License Type"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-agent-hours-usage"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Usage Hours"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "dd-agent-hours-allotment"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Monthly Allotment"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "MAX"
                    }
                  }
                }
              }
            }
            sort_configuration {
              row_sort {
                field_sort {
                  field_id  = "dd-agent-hours-usage"
                  direction = "DESC"
                }
              }
            }
          }
        }
      }
    }

    # ==================== Sheet 3: Asset Inventory (conditional) ====================

    dynamic "sheets" {
      for_each = local.cloudtrail_enabled ? [1] : []
      content {
        sheet_id = "asset-inventory"
        name     = "Asset Inventory"

        sheet_control_layouts {
          configuration {
            grid_layout {
              elements {
                element_type = "FILTER_CONTROL"
                element_id   = "asset-date-picker"
                column_span  = 4
                row_span     = 1
              }
            }
          }
        }

        filter_controls {
          relative_date_time {
            filter_control_id = "asset-date-picker"
            title             = "Date Range"
            source_filter_id  = "asset-date-filter"
          }
        }

        layouts {
          configuration {
            grid_layout {
              # Row 1-7: 5 KPIs (7 row-span each, column-span 7 each, total = 35 + 1 padding)
              elements {
                element_type = "VISUAL"
                element_id   = "kpi-asset-spaces"
                column_index = 0
                row_index    = 1
                column_span  = 7
                row_span     = 7
              }
              elements {
                element_type = "VISUAL"
                element_id   = "kpi-asset-kbs"
                column_index = 7
                row_index    = 1
                column_span  = 7
                row_span     = 7
              }
              elements {
                element_type = "VISUAL"
                element_id   = "kpi-asset-flows"
                column_index = 14
                row_index    = 1
                column_span  = 7
                row_span     = 7
              }
              elements {
                element_type = "VISUAL"
                element_id   = "kpi-asset-agents"
                column_index = 21
                row_index    = 1
                column_span  = 7
                row_span     = 7
              }
              elements {
                element_type = "VISUAL"
                element_id   = "kpi-asset-documents"
                column_index = 28
                row_index    = 1
                column_span  = 8
                row_span     = 7
              }
              # Row 8-15: Asset Creation Trend (stacked area) + Asset Type Breakdown (donut)
              elements {
                element_type = "VISUAL"
                element_id   = "area-asset-creation-trend"
                column_index = 0
                row_index    = 8
                column_span  = 18
                row_span     = 8
              }
              elements {
                element_type = "VISUAL"
                element_id   = "donut-asset-type-breakdown"
                column_index = 18
                row_index    = 8
                column_span  = 18
                row_span     = 8
              }
              # Row 16-23: Top Asset Creators (horiz bar) + KB by Type (bar)
              elements {
                element_type = "VISUAL"
                element_id   = "bar-top-creators"
                column_index = 0
                row_index    = 16
                column_span  = 18
                row_span     = 8
              }
              elements {
                element_type = "VISUAL"
                element_id   = "bar-kb-by-type"
                column_index = 18
                row_index    = 16
                column_span  = 18
                row_span     = 8
              }
              # Row 24-31: Top Uploaders by Size (horiz bar) + Upload Trend (line)
              elements {
                element_type = "VISUAL"
                element_id   = "bar-top-uploaders"
                column_index = 0
                row_index    = 24
                column_span  = 18
                row_span     = 8
              }
              elements {
                element_type = "VISUAL"
                element_id   = "line-upload-trend"
                column_index = 18
                row_index    = 24
                column_span  = 18
                row_span     = 8
              }
              # Row 32-39: Largest Uploads (table) + Uploads by Content Type (donut)
              elements {
                element_type = "VISUAL"
                element_id   = "table-largest-uploads"
                column_index = 0
                row_index    = 32
                column_span  = 18
                row_span     = 8
              }
              elements {
                element_type = "VISUAL"
                element_id   = "donut-uploads-by-type"
                column_index = 18
                row_index    = 32
                column_span  = 18
                row_span     = 8
              }
              # Row 40-47: Spaces Over Time (line) + Mods vs Creates (stacked bar)
              elements {
                element_type = "VISUAL"
                element_id   = "line-spaces-over-time"
                column_index = 0
                row_index    = 40
                column_span  = 18
                row_span     = 8
              }
              elements {
                element_type = "VISUAL"
                element_id   = "bar-mods-vs-creates"
                column_index = 18
                row_index    = 40
                column_span  = 18
                row_span     = 8
              }
              # Row 48-59: BI Assets — 4 KPIs (row 48-55) + 5 charts (rows 56+)
              # Row 48-55: KPI: Total Dashboards | Total Analyses | Total Datasets | Total Datasources
              elements {
                element_type = "VISUAL"
                element_id   = "bi-total-dashboards"
                column_index = 0
                row_index    = 48
                column_span  = 9
                row_span     = 8
              }
              elements {
                element_type = "VISUAL"
                element_id   = "bi-total-analyses"
                column_index = 9
                row_index    = 48
                column_span  = 9
                row_span     = 8
              }
              elements {
                element_type = "VISUAL"
                element_id   = "bi-total-datasets"
                column_index = 18
                row_index    = 48
                column_span  = 9
                row_span     = 8
              }
              elements {
                element_type = "VISUAL"
                element_id   = "bi-total-datasources"
                column_index = 27
                row_index    = 48
                column_span  = 9
                row_span     = 8
              }
              # Row 56-67: Dashboard-Dataset Table | Datasource Type Donut
              elements {
                element_type = "VISUAL"
                element_id   = "bi-dashboard-dataset-table"
                column_index = 0
                row_index    = 56
                column_span  = 18
                row_span     = 12
              }
              elements {
                element_type = "VISUAL"
                element_id   = "bi-datasource-types"
                column_index = 18
                row_index    = 56
                column_span  = 18
                row_span     = 12
              }
              # Row 68-79: Dataset-Datasource Table | Analysis Status Bar
              elements {
                element_type = "VISUAL"
                element_id   = "bi-dataset-datasource-table"
                column_index = 0
                row_index    = 68
                column_span  = 18
                row_span     = 12
              }
              elements {
                element_type = "VISUAL"
                element_id   = "bi-analysis-status"
                column_index = 18
                row_index    = 68
                column_span  = 18
                row_span     = 12
              }
              # Row 80-91: Orphaned Datasets Table (full width)
              elements {
                element_type = "VISUAL"
                element_id   = "bi-orphaned-datasets"
                column_index = 0
                row_index    = 80
                column_span  = 36
                row_span     = 12
              }
              canvas_size_options {
                screen_canvas_size_options {
                  resize_option             = "FIXED"
                  optimized_view_port_width = "1600px"
                }
              }
            }
          }
        }

        # ---- KPI: Total Spaces ----
        visuals {
          kpi_visual {
            visual_id = "kpi-asset-spaces"
            title {
              format_text {
                rich_text = local.asset_kpi_title.spaces
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_kpi_subtitle.spaces
              }
            }
            chart_configuration {
              field_wells {
                values {
                  numerical_measure_field {
                    field_id = "kpi-asset-spaces-value"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Event Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                trend_groups {
                  date_dimension_field {
                    field_id = "kpi-asset-spaces-trend"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "DAY"
                  }
                }
              }
              sort_configuration {
                trend_group_sort {
                  field_sort {
                    field_id  = "kpi-asset-spaces-trend"
                    direction = "ASC"
                  }
                }
              }
              kpi_options {
                trend_arrows {
                  visibility = "VISIBLE"
                }
                sparkline {
                  visibility         = "VISIBLE"
                  type               = "LINE"
                  tooltip_visibility = "VISIBLE"
                }
                primary_value_display_type = "ACTUAL"
              }
            }
          }
        }

        # ---- KPI: Total Knowledge Bases ----
        visuals {
          kpi_visual {
            visual_id = "kpi-asset-kbs"
            title {
              format_text {
                rich_text = local.asset_kpi_title.kbs
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_kpi_subtitle.kbs
              }
            }
            chart_configuration {
              field_wells {
                values {
                  numerical_measure_field {
                    field_id = "kpi-asset-kbs-value"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Event Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                trend_groups {
                  date_dimension_field {
                    field_id = "kpi-asset-kbs-trend"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "DAY"
                  }
                }
              }
              sort_configuration {
                trend_group_sort {
                  field_sort {
                    field_id  = "kpi-asset-kbs-trend"
                    direction = "ASC"
                  }
                }
              }
              kpi_options {
                trend_arrows {
                  visibility = "VISIBLE"
                }
                sparkline {
                  visibility         = "VISIBLE"
                  type               = "LINE"
                  tooltip_visibility = "VISIBLE"
                }
                primary_value_display_type = "ACTUAL"
              }
            }
          }
        }

        # ---- KPI: Total Flows ----
        visuals {
          kpi_visual {
            visual_id = "kpi-asset-flows"
            title {
              format_text {
                rich_text = local.asset_kpi_title.flows
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_kpi_subtitle.flows
              }
            }
            chart_configuration {
              field_wells {
                values {
                  numerical_measure_field {
                    field_id = "kpi-asset-flows-value"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Event Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                trend_groups {
                  date_dimension_field {
                    field_id = "kpi-asset-flows-trend"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "DAY"
                  }
                }
              }
              sort_configuration {
                trend_group_sort {
                  field_sort {
                    field_id  = "kpi-asset-flows-trend"
                    direction = "ASC"
                  }
                }
              }
              kpi_options {
                trend_arrows {
                  visibility = "VISIBLE"
                }
                sparkline {
                  visibility         = "VISIBLE"
                  type               = "LINE"
                  tooltip_visibility = "VISIBLE"
                }
                primary_value_display_type = "ACTUAL"
              }
            }
          }
        }

        # ---- KPI: Total Agents ----
        visuals {
          kpi_visual {
            visual_id = "kpi-asset-agents"
            title {
              format_text {
                rich_text = local.asset_kpi_title.agents
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_kpi_subtitle.agents
              }
            }
            chart_configuration {
              field_wells {
                values {
                  numerical_measure_field {
                    field_id = "kpi-asset-agents-value"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Event Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                trend_groups {
                  date_dimension_field {
                    field_id = "kpi-asset-agents-trend"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "DAY"
                  }
                }
              }
              sort_configuration {
                trend_group_sort {
                  field_sort {
                    field_id  = "kpi-asset-agents-trend"
                    direction = "ASC"
                  }
                }
              }
              kpi_options {
                trend_arrows {
                  visibility = "VISIBLE"
                }
                sparkline {
                  visibility         = "VISIBLE"
                  type               = "LINE"
                  tooltip_visibility = "VISIBLE"
                }
                primary_value_display_type = "ACTUAL"
              }
            }
          }
        }

        # ---- KPI: Total Documents ----
        visuals {
          kpi_visual {
            visual_id = "kpi-asset-documents"
            title {
              format_text {
                rich_text = local.asset_kpi_title.documents
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_kpi_subtitle.documents
              }
            }
            chart_configuration {
              field_wells {
                values {
                  numerical_measure_field {
                    field_id = "kpi-asset-documents-value"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Event Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                trend_groups {
                  date_dimension_field {
                    field_id = "kpi-asset-documents-trend"
                    column {
                      data_set_identifier = "asset-inventory"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "DAY"
                  }
                }
              }
              sort_configuration {
                trend_group_sort {
                  field_sort {
                    field_id  = "kpi-asset-documents-trend"
                    direction = "ASC"
                  }
                }
              }
              kpi_options {
                trend_arrows {
                  visibility = "VISIBLE"
                }
                sparkline {
                  visibility         = "VISIBLE"
                  type               = "LINE"
                  tooltip_visibility = "VISIBLE"
                }
                primary_value_display_type = "ACTUAL"
              }
            }
          }
        }

        # ---- Chart: Asset Creation Trend (stacked area) ----
        visuals {
          line_chart_visual {
            visual_id = "area-asset-creation-trend"
            title {
              format_text {
                rich_text = local.asset_chart_title.creation_trend
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.creation_trend
              }
            }
            chart_configuration {
              field_wells {
                line_chart_aggregated_field_wells {
                  category {
                    date_dimension_field {
                      field_id = "area-creation-trend-month"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Timestamp"
                      }
                      date_granularity = "MONTH"
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "area-creation-trend-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Event Count"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                  colors {
                    categorical_dimension_field {
                      field_id = "area-creation-trend-color"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Asset Type"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "area-creation-trend-month"
                    direction = "ASC"
                  }
                }
              }
              type = "STACKED_AREA"
            }
          }
        }

        # ---- Chart: Asset Type Breakdown (donut) ----
        visuals {
          pie_chart_visual {
            visual_id = "donut-asset-type-breakdown"
            title {
              format_text {
                rich_text = local.asset_chart_title.type_breakdown
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.type_breakdown
              }
            }
            chart_configuration {
              field_wells {
                pie_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "donut-type-breakdown-group"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Asset Type"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "donut-type-breakdown-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Event Count"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              donut_options {
                arc_options {
                  arc_thickness = "WHOLE"
                }
              }
            }
          }
        }

        # ---- Chart: Top Asset Creators (horizontal bar) ----
        visuals {
          bar_chart_visual {
            visual_id = "bar-top-creators"
            title {
              format_text {
                rich_text = local.asset_chart_title.top_creators
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.top_creators
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "bar-top-creators-category"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Username"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "bar-top-creators-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Event Count"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "bar-top-creators-value"
                    direction = "DESC"
                  }
                }
                category_items_limit {
                  items_limit      = 10
                  other_categories = "INCLUDE"
                }
                color_items_limit {
                  other_categories = "INCLUDE"
                }
                small_multiples_limit_configuration {
                  items_limit      = 1
                  other_categories = "INCLUDE"
                }
              }
              orientation = "HORIZONTAL"
            }
          }
        }

        # ---- Chart: KB by Type (vertical bar) ----
        visuals {
          bar_chart_visual {
            visual_id = "bar-kb-by-type"
            title {
              format_text {
                rich_text = local.asset_chart_title.kb_by_type
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.kb_by_type
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "bar-kb-by-type-category"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "KB Type"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "bar-kb-by-type-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Event Count"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "bar-kb-by-type-value"
                    direction = "DESC"
                  }
                }
              }
              orientation = "VERTICAL"
            }
          }
        }

        # ---- Chart: Top Uploaders by Size (horizontal bar) ----
        visuals {
          bar_chart_visual {
            visual_id = "bar-top-uploaders"
            title {
              format_text {
                rich_text = local.asset_chart_title.top_uploaders
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.top_uploaders
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "bar-top-uploaders-category"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Username"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "bar-top-uploaders-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "File Size (MB)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "bar-top-uploaders-value"
                    direction = "DESC"
                  }
                }
                category_items_limit {
                  items_limit      = 10
                  other_categories = "INCLUDE"
                }
                color_items_limit {
                  other_categories = "INCLUDE"
                }
                small_multiples_limit_configuration {
                  items_limit      = 1
                  other_categories = "INCLUDE"
                }
              }
              orientation = "HORIZONTAL"
            }
          }
        }

        # ---- Chart: Upload Trend (line) ----
        visuals {
          line_chart_visual {
            visual_id = "line-upload-trend"
            title {
              format_text {
                rich_text = local.asset_chart_title.upload_trend
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.upload_trend
              }
            }
            chart_configuration {
              field_wells {
                line_chart_aggregated_field_wells {
                  category {
                    date_dimension_field {
                      field_id = "line-upload-trend-month"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Timestamp"
                      }
                      date_granularity = "MONTH"
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "line-upload-trend-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "File Size (MB)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "line-upload-trend-month"
                    direction = "ASC"
                  }
                }
              }
              type = "LINE"
            }
          }
        }

        # ---- Chart: Largest Uploads (table) ----
        visuals {
          table_visual {
            visual_id = "table-largest-uploads"
            title {
              format_text {
                rich_text = local.asset_chart_title.largest_uploads
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.largest_uploads
              }
            }
            chart_configuration {
              field_wells {
                table_aggregated_field_wells {
                  group_by {
                    categorical_dimension_field {
                      field_id = "table-largest-uploads-filename"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "File Name"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "table-largest-uploads-contenttype"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Content Type"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "table-largest-uploads-userid"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Username"
                      }
                    }
                  }
                  group_by {
                    date_dimension_field {
                      field_id = "table-largest-uploads-timestamp"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Timestamp"
                      }
                      date_granularity = "DAY"
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "table-largest-uploads-size"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "File Size (MB)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                row_sort {
                  field_sort {
                    field_id  = "table-largest-uploads-size"
                    direction = "DESC"
                  }
                }
              }
            }
          }
        }

        # ---- Chart: Uploads by Content Type (donut) ----
        visuals {
          pie_chart_visual {
            visual_id = "donut-uploads-by-type"
            title {
              format_text {
                rich_text = local.asset_chart_title.uploads_by_type
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.uploads_by_type
              }
            }
            chart_configuration {
              field_wells {
                pie_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "donut-uploads-by-type-group"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Content Type"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "donut-uploads-by-type-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "File Size (MB)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              donut_options {
                arc_options {
                  arc_thickness = "WHOLE"
                }
              }
            }
          }
        }

        # ---- Chart: Spaces Created Over Time (line) ----
        visuals {
          line_chart_visual {
            visual_id = "line-spaces-over-time"
            title {
              format_text {
                rich_text = local.asset_chart_title.spaces_over_time
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.spaces_over_time
              }
            }
            chart_configuration {
              field_wells {
                line_chart_aggregated_field_wells {
                  category {
                    date_dimension_field {
                      field_id = "line-spaces-over-time-month"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Timestamp"
                      }
                      date_granularity = "MONTH"
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "line-spaces-over-time-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Event Count"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "line-spaces-over-time-month"
                    direction = "ASC"
                  }
                }
              }
              type = "LINE"
            }
          }
        }

        # ---- Chart: Asset Modifications vs Creations (stacked bar) ----
        visuals {
          bar_chart_visual {
            visual_id = "bar-mods-vs-creates"
            title {
              format_text {
                rich_text = local.asset_chart_title.mods_vs_creates
              }
            }
            subtitle {
              format_text {
                rich_text = local.asset_chart_subtitle.mods_vs_creates
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    date_dimension_field {
                      field_id = "bar-mods-vs-creates-month"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Timestamp"
                      }
                      date_granularity = "MONTH"
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "bar-mods-vs-creates-value"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Event Count"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                  colors {
                    categorical_dimension_field {
                      field_id = "bar-mods-vs-creates-color"
                      column {
                        data_set_identifier = "asset-inventory"
                        column_name         = "Operation"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "bar-mods-vs-creates-month"
                    direction = "ASC"
                  }
                }
              }
              orientation    = "VERTICAL"
              bars_arrangement = "STACKED"
            }
          }
        }

        # ==================== BI Assets Section ====================

        # ---- KPI: Total Dashboards ----
        visuals {
          kpi_visual {
            visual_id = "bi-total-dashboards"
            title {
              format_text {
                rich_text = local.bi_asset_title.total_dashboards
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.total_dashboards
              }
            }
            chart_configuration {
              field_wells {
                values {
                  categorical_measure_field {
                    field_id = "bi-total-dashboards-value"
                    column {
                      data_set_identifier = "bi-assets"
                      column_name         = "ID"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
              }
            }
          }
        }

        # ---- KPI: Total Analyses ----
        visuals {
          kpi_visual {
            visual_id = "bi-total-analyses"
            title {
              format_text {
                rich_text = local.bi_asset_title.total_analyses
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.total_analyses
              }
            }
            chart_configuration {
              field_wells {
                values {
                  categorical_measure_field {
                    field_id = "bi-total-analyses-value"
                    column {
                      data_set_identifier = "bi-assets"
                      column_name         = "ID"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
              }
            }
          }
        }

        # ---- KPI: Total Datasets ----
        visuals {
          kpi_visual {
            visual_id = "bi-total-datasets"
            title {
              format_text {
                rich_text = local.bi_asset_title.total_datasets
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.total_datasets
              }
            }
            chart_configuration {
              field_wells {
                values {
                  categorical_measure_field {
                    field_id = "bi-total-datasets-value"
                    column {
                      data_set_identifier = "bi-assets"
                      column_name         = "Dataset ID"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
              }
            }
          }
        }

        # ---- KPI: Total Data Sources ----
        visuals {
          kpi_visual {
            visual_id = "bi-total-datasources"
            title {
              format_text {
                rich_text = local.bi_asset_title.total_datasources
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.total_datasources
              }
            }
            chart_configuration {
              field_wells {
                values {
                  categorical_measure_field {
                    field_id = "bi-total-datasources-value"
                    column {
                      data_set_identifier = "bi-assets"
                      column_name         = "ID"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
              }
            }
          }
        }

        # ---- Table: Dashboard → Dataset ----
        visuals {
          table_visual {
            visual_id = "bi-dashboard-dataset-table"
            title {
              format_text {
                rich_text = local.bi_asset_title.dashboard_dataset_table
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.dashboard_dataset_table
              }
            }
            chart_configuration {
              field_wells {
                table_aggregated_field_wells {
                  group_by {
                    categorical_dimension_field {
                      field_id = "bi-dash-table-name"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "Name"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "bi-dash-table-dataset"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "Dataset Name"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                row_sort {
                  field_sort {
                    field_id  = "bi-dash-table-name"
                    direction = "ASC"
                  }
                }
              }
            }
          }
        }

        # ---- Table: Dataset → Datasource ----
        visuals {
          table_visual {
            visual_id = "bi-dataset-datasource-table"
            title {
              format_text {
                rich_text = local.bi_asset_title.dataset_datasource_table
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.dataset_datasource_table
              }
            }
            chart_configuration {
              field_wells {
                table_aggregated_field_wells {
                  group_by {
                    categorical_dimension_field {
                      field_id = "bi-ds-table-dataset"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "Dataset Name"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "bi-ds-table-name"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "Name"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "bi-ds-table-type"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "Datasource Type"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                row_sort {
                  field_sort {
                    field_id  = "bi-ds-table-dataset"
                    direction = "ASC"
                  }
                }
              }
            }
          }
        }

        # ---- Donut: Datasource Types ----
        visuals {
          pie_chart_visual {
            visual_id = "bi-datasource-types"
            title {
              format_text {
                rich_text = local.bi_asset_title.datasource_types
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.datasource_types
              }
            }
            chart_configuration {
              field_wells {
                pie_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "bi-datasource-types-group"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "Datasource Type"
                      }
                    }
                  }
                  values {
                    categorical_measure_field {
                      field_id = "bi-datasource-types-value"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "ID"
                      }
                      aggregation_function = "DISTINCT_COUNT"
                    }
                  }
                }
              }
              donut_options {
                arc_options {
                  arc_thickness = "WHOLE"
                }
              }
            }
          }
        }

        # ---- Bar: Analysis Status ----
        visuals {
          bar_chart_visual {
            visual_id = "bi-analysis-status"
            title {
              format_text {
                rich_text = local.bi_asset_title.analysis_status
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.analysis_status
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "bi-analysis-status-category"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "Status"
                      }
                    }
                  }
                  values {
                    categorical_measure_field {
                      field_id = "bi-analysis-status-value"
                      column {
                        data_set_identifier = "bi-assets"
                        column_name         = "ID"
                      }
                      aggregation_function = "DISTINCT_COUNT"
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "bi-analysis-status-value"
                    direction = "DESC"
                  }
                }
                category_items_limit {
                  items_limit      = 10
                  other_categories = "INCLUDE"
                }
                color_items_limit {
                  other_categories = "INCLUDE"
                }
                small_multiples_limit_configuration {
                  items_limit      = 1
                  other_categories = "INCLUDE"
                }
              }
              orientation = "HORIZONTAL"
            }
          }
        }

        # ---- Table: Orphaned Datasets ----
        visuals {
          table_visual {
            visual_id = "bi-orphaned-datasets"
            title {
              format_text {
                rich_text = local.bi_asset_title.orphaned_datasets
              }
            }
            subtitle {
              format_text {
                rich_text = local.bi_asset_subtitle.orphaned_datasets
              }
            }
            chart_configuration {
              field_wells {
                table_aggregated_field_wells {
                  group_by {
                    categorical_dimension_field {
                      field_id = "bi-orphaned-name"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Name"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "bi-orphaned-dataset-id"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Dataset ID"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "bi-orphaned-last-updated"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Last Updated"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                row_sort {
                  field_sort {
                    field_id  = "bi-orphaned-name"
                    direction = "ASC"
                  }
                }
              }
            }
          }
        }
      }
    }

    # ==================== Sheet 4: Categorization ====================

    sheets {
      sheet_id = "categorization"
      name     = "Usage Insights"

      sheet_control_layouts {
        configuration {
          grid_layout {
            elements {
              element_type = "FILTER_CONTROL"
              element_id   = "cat-date-picker"
              column_span  = 4
              row_span     = 1
            }
          }
        }
      }

      filter_controls {
        relative_date_time {
          filter_control_id = "cat-date-picker"
          title             = "Date Range"
          source_filter_id  = "cat-date-filter"
        }
      }

      layouts {
        configuration {
          grid_layout {
            # Row 0-11: Category Distribution (left) | Intent Distribution (right)
            elements {
              element_type = "VISUAL"
              element_id   = "cat-category-dist"
              column_index = 0
              row_index    = 0
              column_span  = 18
              row_span     = 12
            }
            elements {
              element_type = "VISUAL"
              element_id   = "cat-intent-dist"
              column_index = 18
              row_index    = 0
              column_span  = 18
              row_span     = 12
            }
            # Row 12-23: Category x Intent Heatmap (left) | Category Trend (right)
            elements {
              element_type = "VISUAL"
              element_id   = "cat-heatmap"
              column_index = 0
              row_index    = 12
              column_span  = 18
              row_span     = 12
            }
            elements {
              element_type = "VISUAL"
              element_id   = "cat-trend"
              column_index = 18
              row_index    = 12
              column_span  = 18
              row_span     = 12
            }
            # Row 24-35: Customer Info Pie (left) | Categories by Dept (right)
            elements {
              element_type = "VISUAL"
              element_id   = "cat-customer-info"
              column_index = 0
              row_index    = 24
              column_span  = 18
              row_span     = 12
            }
            elements {
              element_type = "VISUAL"
              element_id   = "cat-dept-bar"
              column_index = 18
              row_index    = 24
              column_span  = 18
              row_span     = 12
            }
            # Row 36-49: Top Users by Messages | Top Users by Conversations | Idle Users
            elements {
              element_type = "VISUAL"
              element_id   = "cat-top-by-messages"
              column_index = 0
              row_index    = 36
              column_span  = 12
              row_span     = 14
            }
            elements {
              element_type = "VISUAL"
              element_id   = "cat-top-by-conversations"
              column_index = 12
              row_index    = 36
              column_span  = 12
              row_span     = 14
            }
            elements {
              element_type = "VISUAL"
              element_id   = "cat-idle-users"
              column_index = 24
              row_index    = 36
              column_span  = 12
              row_span     = 14
            }
          }
        }
      }

      # Visual 1 — Prompt Category Distribution (horizontal bar)
      visuals {
        bar_chart_visual {
          visual_id = "cat-category-dist"
          title {
            format_text {
              rich_text = local.cat_title.category_distribution
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.category_distribution
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "cat-cat-dim"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Prompt Category"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "cat-cat-val"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            orientation = "HORIZONTAL"
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "cat-cat-val"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 13
                other_categories = "INCLUDE"
              }
              color_items_limit {
                items_limit      = 13
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 13
                other_categories = "INCLUDE"
              }
            }
          }
        }
      }

      # Visual 2 — Action Intent Distribution (horizontal bar)
      visuals {
        bar_chart_visual {
          visual_id = "cat-intent-dist"
          title {
            format_text {
              rich_text = local.cat_title.intent_distribution
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.intent_distribution
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "cat-int-dim"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Action Intent"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "cat-int-val"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            orientation = "HORIZONTAL"
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "cat-int-val"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 17
                other_categories = "INCLUDE"
              }
              color_items_limit {
                items_limit      = 17
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 17
                other_categories = "INCLUDE"
              }
            }
          }
        }
      }

      # Visual 3 — Category x Intent Heatmap
      visuals {
        heat_map_visual {
          visual_id = "cat-heatmap"
          title {
            format_text {
              rich_text = local.cat_title.category_intent_heat
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.category_intent_heat
            }
          }
          chart_configuration {
            field_wells {
              heat_map_aggregated_field_wells {
                rows {
                  categorical_dimension_field {
                    field_id = "cat-heat-row"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Prompt Category"
                    }
                  }
                }
                columns {
                  categorical_dimension_field {
                    field_id = "cat-heat-col"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Action Intent"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "cat-heat-val"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
          }
        }
      }

      # Visual 4 — Category Trend Over Time (stacked area line chart)
      visuals {
        line_chart_visual {
          visual_id = "cat-trend"
          title {
            format_text {
              rich_text = local.cat_title.category_trend
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.category_trend
            }
          }
          chart_configuration {
            field_wells {
              line_chart_aggregated_field_wells {
                category {
                  date_dimension_field {
                    field_id = "cat-trend-date"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Timestamp"
                    }
                    date_granularity = "WEEK"
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "cat-trend-val"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                colors {
                  categorical_dimension_field {
                    field_id = "cat-trend-color"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Prompt Category"
                    }
                  }
                }
              }
            }
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "cat-trend-date"
                  direction = "ASC"
                }
              }
            }
          }
        }
      }

      # Visual 5 — Contains Customer Info (pie chart)
      visuals {
        pie_chart_visual {
          visual_id = "cat-customer-info"
          title {
            format_text {
              rich_text = local.cat_title.customer_info_pie
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.customer_info_pie
            }
          }
          chart_configuration {
            field_wells {
              pie_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "cat-pie-cat"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Contains Customer Info"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "cat-pie-val"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            donut_options {
              arc_options {
                arc_thickness = "WHOLE"
              }
            }
          }
        }
      }

      # Visual 6 — Top Categories by Department (stacked horizontal bar)
      visuals {
        bar_chart_visual {
          visual_id = "cat-dept-bar"
          title {
            format_text {
              rich_text = local.cat_title.category_by_dept
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.category_by_dept
            }
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "cat-dept-dim"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Department"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "cat-dept-val"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
                colors {
                  categorical_dimension_field {
                    field_id = "cat-dept-color"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Prompt Category"
                    }
                  }
                }
              }
            }
            orientation = "HORIZONTAL"
            sort_configuration {
              category_sort {
                field_sort {
                  field_id  = "cat-dept-val"
                  direction = "DESC"
                }
              }
              category_items_limit {
                items_limit      = 10
                other_categories = "INCLUDE"
              }
              color_items_limit {
                items_limit      = 6
                other_categories = "INCLUDE"
              }
              small_multiples_limit_configuration {
                items_limit      = 10
                other_categories = "INCLUDE"
              }
            }
          }
        }
      }
      # Top Users by Messages (table)
      visuals {
        table_visual {
          visual_id = "cat-top-by-messages"
          title {
            format_text {
              rich_text = local.cat_title.top_by_messages
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.top_by_messages
            }
          }
          chart_configuration {
            field_wells {
              table_aggregated_field_wells {
                group_by {
                  categorical_dimension_field {
                    field_id = "cat-top-msg-name"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Name"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "cat-top-msg-email"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Email"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "cat-top-msg-count"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Message Count"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
            sort_configuration {
              row_sort {
                field_sort {
                  field_id  = "cat-top-msg-count"
                  direction = "DESC"
                }
              }
            }
          }
        }
      }

      # Top Users by Conversations (table)
      visuals {
        table_visual {
          visual_id = "cat-top-by-conversations"
          title {
            format_text {
              rich_text = local.cat_title.top_by_conversations
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.top_by_conversations
            }
          }
          chart_configuration {
            field_wells {
              table_aggregated_field_wells {
                group_by {
                  categorical_dimension_field {
                    field_id = "cat-top-conv-name"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Name"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "cat-top-conv-email"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Email"
                    }
                  }
                }
                values {
                  categorical_measure_field {
                    field_id = "cat-top-conv-count"
                    column {
                      data_set_identifier = "messages"
                      column_name         = "Conversation"
                    }
                    aggregation_function = "DISTINCT_COUNT"
                  }
                }
              }
            }
            sort_configuration {
              row_sort {
                field_sort {
                  field_id  = "cat-top-conv-count"
                  direction = "DESC"
                }
              }
            }
          }
        }
      }

      # Idle Users (table — from idle-users dataset)
      visuals {
        table_visual {
          visual_id = "cat-idle-users"
          title {
            format_text {
              rich_text = local.cat_title.idle_users
            }
          }
          subtitle {
            format_text {
              rich_text = local.cat_subtitle.idle_users
            }
          }
          chart_configuration {
            field_wells {
              table_aggregated_field_wells {
                group_by {
                  categorical_dimension_field {
                    field_id = "cat-idle-name"
                    column {
                      data_set_identifier = "idle-users"
                      column_name         = "Name"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "cat-idle-email"
                    column {
                      data_set_identifier = "idle-users"
                      column_name         = "Email"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "cat-idle-dept"
                    column {
                      data_set_identifier = "idle-users"
                      column_name         = "Department"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    # ==================== Sheet 5: SPICE & Data Health ====================

    dynamic "sheets" {
      for_each = var.spice_enabled ? [1] : []
      content {
        sheet_id = "spice-health"
        name     = "SPICE & Data Health"

        layouts {
          configuration {
            grid_layout {
              # Row 0-11: SPICE Utilization KPI | SPICE Gauge | SPICE Trend
              elements {
                element_type = "VISUAL"
                element_id   = "spice-utilization-kpi"
                column_index = 0
                row_index    = 0
                column_span  = 12
                row_span     = 12
              }
              elements {
                element_type = "VISUAL"
                element_id   = "spice-gauge"
                column_index = 12
                row_index    = 0
                column_span  = 12
                row_span     = 12
              }
              elements {
                element_type = "VISUAL"
                element_id   = "spice-trend"
                column_index = 24
                row_index    = 0
                column_span  = 12
                row_span     = 12
              }
              # Row 12-23: Ingestion Status Donut | Failed Ingestions Table | Refresh Latency Bar
              elements {
                element_type = "VISUAL"
                element_id   = "health-ingestion-status"
                column_index = 0
                row_index    = 12
                column_span  = 12
                row_span     = 12
              }
              elements {
                element_type = "VISUAL"
                element_id   = "health-failed-table"
                column_index = 12
                row_index    = 12
                column_span  = 12
                row_span     = 12
              }
              elements {
                element_type = "VISUAL"
                element_id   = "health-latency"
                column_index = 24
                row_index    = 12
                column_span  = 12
                row_span     = 12
              }
              # Row 24-35: Top Datasets by SPICE | Rows Ingested vs Dropped | Import Mode Donut
              elements {
                element_type = "VISUAL"
                element_id   = "health-top-spice"
                column_index = 0
                row_index    = 24
                column_span  = 12
                row_span     = 12
              }
              elements {
                element_type = "VISUAL"
                element_id   = "health-rows"
                column_index = 12
                row_index    = 24
                column_span  = 12
                row_span     = 12
              }
              elements {
                element_type = "VISUAL"
                element_id   = "health-import-mode"
                column_index = 24
                row_index    = 24
                column_span  = 12
                row_span     = 12
              }
              canvas_size_options {
                screen_canvas_size_options {
                  resize_option             = "FIXED"
                  optimized_view_port_width = "1600px"
                }
              }
            }
          }
        }

        # ---- KPI: SPICE Utilization % ----
        visuals {
          kpi_visual {
            visual_id = "spice-utilization-kpi"
            title {
              format_text {
                rich_text = local.spice_title.utilization
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.utilization
              }
            }
            chart_configuration {
              field_wells {
                values {
                  numerical_measure_field {
                    field_id = "spice-util-consumed"
                    column {
                      data_set_identifier = "spice-capacity"
                      column_name         = "SPICE Consumed (MB)"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "MAX"
                    }
                  }
                }
                target_values {
                  numerical_measure_field {
                    field_id = "spice-util-limit"
                    column {
                      data_set_identifier = "spice-capacity"
                      column_name         = "SPICE Limit (MB)"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "MAX"
                    }
                  }
                }
              }
              kpi_options {
                comparison {
                  comparison_method = "PERCENT_DIFFERENCE"
                }
                primary_value_display_type = "ACTUAL"
              }
            }
          }
        }

        # ---- Bar: SPICE Capacity Gauge ----
        visuals {
          bar_chart_visual {
            visual_id = "spice-gauge"
            title {
              format_text {
                rich_text = local.spice_title.gauge
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.gauge
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    date_dimension_field {
                      field_id = "spice-gauge-category"
                      column {
                        data_set_identifier = "spice-capacity"
                        column_name         = "Timestamp"
                      }
                      date_granularity = "DAY"
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "spice-gauge-consumed"
                      column {
                        data_set_identifier = "spice-capacity"
                        column_name         = "SPICE Consumed (MB)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "MAX"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "spice-gauge-limit"
                      column {
                        data_set_identifier = "spice-capacity"
                        column_name         = "SPICE Limit (MB)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "MAX"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "spice-gauge-category"
                    direction = "DESC"
                  }
                }
                category_items_limit {
                  items_limit      = 1
                  other_categories = "INCLUDE"
                }
                color_items_limit {
                  other_categories = "INCLUDE"
                }
                small_multiples_limit_configuration {
                  items_limit      = 1
                  other_categories = "INCLUDE"
                }
              }
              orientation = "HORIZONTAL"
            }
          }
        }

        # ---- Line: SPICE Capacity Trend ----
        visuals {
          line_chart_visual {
            visual_id = "spice-trend"
            title {
              format_text {
                rich_text = local.spice_title.trend
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.trend
              }
            }
            chart_configuration {
              field_wells {
                line_chart_aggregated_field_wells {
                  category {
                    date_dimension_field {
                      field_id = "spice-trend-date"
                      column {
                        data_set_identifier = "spice-capacity"
                        column_name         = "Timestamp"
                      }
                      date_granularity = "DAY"
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "spice-trend-consumed"
                      column {
                        data_set_identifier = "spice-capacity"
                        column_name         = "SPICE Consumed (MB)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "MAX"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "spice-trend-limit"
                      column {
                        data_set_identifier = "spice-capacity"
                        column_name         = "SPICE Limit (MB)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "MAX"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "spice-trend-date"
                    direction = "ASC"
                  }
                }
              }
              type = "LINE"
            }
          }
        }

        # ---- Donut: Ingestion Status ----
        visuals {
          pie_chart_visual {
            visual_id = "health-ingestion-status"
            title {
              format_text {
                rich_text = local.spice_title.ingestion
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.ingestion
              }
            }
            chart_configuration {
              field_wells {
                pie_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "health-ingestion-status-group"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Ingestion Status"
                      }
                    }
                  }
                  values {
                    categorical_measure_field {
                      field_id = "health-ingestion-status-value"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Name"
                      }
                      aggregation_function = "DISTINCT_COUNT"
                    }
                  }
                }
              }
              donut_options {
                arc_options {
                  arc_thickness = "WHOLE"
                }
              }
            }
          }
        }

        # ---- Table: Failed Ingestions ----
        visuals {
          table_visual {
            visual_id = "health-failed-table"
            title {
              format_text {
                rich_text = local.spice_title.failed
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.failed
              }
            }
            chart_configuration {
              field_wells {
                table_aggregated_field_wells {
                  group_by {
                    categorical_dimension_field {
                      field_id = "health-failed-name"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Name"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "health-failed-error-type"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Error Type"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "health-failed-error-msg"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Error Message"
                      }
                    }
                  }
                  group_by {
                    categorical_dimension_field {
                      field_id = "health-failed-triggered"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Refresh Triggered At"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                row_sort {
                  field_sort {
                    field_id  = "health-failed-triggered"
                    direction = "DESC"
                  }
                }
              }
            }
          }
        }

        # ---- Bar: Dataset Refresh Latency ----
        visuals {
          bar_chart_visual {
            visual_id = "health-latency"
            title {
              format_text {
                rich_text = local.spice_title.latency
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.latency
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "health-latency-name"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Name"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "health-latency-value"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Refresh Duration (s)"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "AVERAGE"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "health-latency-value"
                    direction = "DESC"
                  }
                }
                category_items_limit {
                  items_limit      = 20
                  other_categories = "INCLUDE"
                }
                color_items_limit {
                  other_categories = "INCLUDE"
                }
                small_multiples_limit_configuration {
                  items_limit      = 1
                  other_categories = "INCLUDE"
                }
              }
              orientation = "HORIZONTAL"
            }
          }
        }

        # ---- Bar: Top Datasets by SPICE ----
        visuals {
          bar_chart_visual {
            visual_id = "health-top-spice"
            title {
              format_text {
                rich_text = local.spice_title.top_spice
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.top_spice
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "health-top-spice-name"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Name"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "health-top-spice-value"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "SPICE Bytes"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "health-top-spice-value"
                    direction = "DESC"
                  }
                }
                category_items_limit {
                  items_limit      = 20
                  other_categories = "INCLUDE"
                }
                color_items_limit {
                  other_categories = "INCLUDE"
                }
                small_multiples_limit_configuration {
                  items_limit      = 1
                  other_categories = "INCLUDE"
                }
              }
              orientation = "HORIZONTAL"
            }
          }
        }

        # ---- Bar: Rows Ingested vs Dropped ----
        visuals {
          bar_chart_visual {
            visual_id = "health-rows"
            title {
              format_text {
                rich_text = local.spice_title.rows
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.rows
              }
            }
            chart_configuration {
              field_wells {
                bar_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "health-rows-name"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Name"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "health-rows-ingested"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Rows Ingested"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                  values {
                    numerical_measure_field {
                      field_id = "health-rows-dropped"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Rows Dropped"
                      }
                      aggregation_function {
                        simple_numerical_aggregation = "SUM"
                      }
                    }
                  }
                }
              }
              sort_configuration {
                category_sort {
                  field_sort {
                    field_id  = "health-rows-ingested"
                    direction = "DESC"
                  }
                }
                category_items_limit {
                  items_limit      = 20
                  other_categories = "INCLUDE"
                }
                color_items_limit {
                  other_categories = "INCLUDE"
                }
                small_multiples_limit_configuration {
                  items_limit      = 1
                  other_categories = "INCLUDE"
                }
              }
              orientation    = "HORIZONTAL"
              bars_arrangement = "STACKED"
            }
          }
        }

        # ---- Donut: Datasets by Import Mode ----
        visuals {
          pie_chart_visual {
            visual_id = "health-import-mode"
            title {
              format_text {
                rich_text = local.spice_title.import_mode
              }
            }
            subtitle {
              format_text {
                rich_text = local.spice_subtitle.import_mode
              }
            }
            chart_configuration {
              field_wells {
                pie_chart_aggregated_field_wells {
                  category {
                    categorical_dimension_field {
                      field_id = "health-import-mode-group"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Import Mode"
                      }
                    }
                  }
                  values {
                    categorical_measure_field {
                      field_id = "health-import-mode-value"
                      column {
                        data_set_identifier = "dataset-health"
                        column_name         = "Name"
                      }
                      aggregation_function = "DISTINCT_COUNT"
                    }
                  }
                }
              }
              donut_options {
                arc_options {
                  arc_thickness = "WHOLE"
                }
              }
            }
          }
        }
      }
    }
  }

  permissions {
    actions = [
      "quicksight:RestoreAnalysis",
      "quicksight:UpdateAnalysisPermissions",
      "quicksight:DeleteAnalysis",
      "quicksight:QueryAnalysis",
      "quicksight:DescribeAnalysisPermissions",
      "quicksight:DescribeAnalysis",
      "quicksight:UpdateAnalysis",
    ]
    principal = local.qs_principal
  }
}

resource "aws_quicksight_template" "quicksuite" {
  template_id         = "quicksuite-analytics"
  name                = "Amazon Quick Suite Adoption Template"
  version_description = "v11"

  source_entity {
    source_analysis {
      arn = aws_quicksight_analysis.quicksuite.arn
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.messages.arn
        data_set_placeholder = "messages"
      }
      dynamic "data_set_references" {
        for_each = local.cloudtrail_enabled ? [1] : []
        content {
          data_set_arn         = aws_quicksight_data_set.asset_inventory[0].arn
          data_set_placeholder = "asset-inventory"
        }
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.plugin_utilization.arn
        data_set_placeholder = "plugin-utilization"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.resource_selections.arn
        data_set_placeholder = "resource-selections"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.bi_assets.arn
        data_set_placeholder = "bi-assets"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.dataset_health.arn
        data_set_placeholder = "dataset-health"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.idle_users.arn
        data_set_placeholder = "idle-users"
      }
      dynamic "data_set_references" {
        for_each = var.spice_enabled ? [1] : []
        content {
          data_set_arn         = aws_quicksight_data_set.spice_capacity[0].arn
          data_set_placeholder = "spice-capacity"
        }
      }
    }
  }

  permissions {
    actions   = ["quicksight:DescribeTemplate"]
    principal = local.qs_principal
  }
}

resource "aws_quicksight_dashboard" "quicksuite" {
  dashboard_id        = "quicksuite-analytics"
  name                = "Amazon Quick Suite Adoption"
  version_description = "v11"

  source_entity {
    source_template {
      arn = aws_quicksight_template.quicksuite.arn
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.messages.arn
        data_set_placeholder = "messages"
      }
      dynamic "data_set_references" {
        for_each = local.cloudtrail_enabled ? [1] : []
        content {
          data_set_arn         = aws_quicksight_data_set.asset_inventory[0].arn
          data_set_placeholder = "asset-inventory"
        }
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.plugin_utilization.arn
        data_set_placeholder = "plugin-utilization"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.resource_selections.arn
        data_set_placeholder = "resource-selections"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.bi_assets.arn
        data_set_placeholder = "bi-assets"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.dataset_health.arn
        data_set_placeholder = "dataset-health"
      }
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.idle_users.arn
        data_set_placeholder = "idle-users"
      }
      dynamic "data_set_references" {
        for_each = var.spice_enabled ? [1] : []
        content {
          data_set_arn         = aws_quicksight_data_set.spice_capacity[0].arn
          data_set_placeholder = "spice-capacity"
        }
      }
    }
  }

  permissions {
    actions = [
      "quicksight:DescribeDashboard",
      "quicksight:ListDashboardVersions",
      "quicksight:UpdateDashboardPermissions",
      "quicksight:QueryDashboard",
      "quicksight:UpdateDashboard",
      "quicksight:DeleteDashboard",
      "quicksight:DescribeDashboardPermissions",
      "quicksight:UpdateDashboardPublishedVersion",
    ]
    principal = local.qs_principal
  }
}
