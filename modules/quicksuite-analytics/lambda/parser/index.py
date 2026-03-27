import json
import gzip
import uuid
import boto3

s3 = boto3.client("s3")


def derive_query_scope(record):
    """Derive query_scope from message_scope + user_selected_resources."""
    scope = record.get("message_scope", "")
    if scope == "no_resources":
        return "No Resources Selected"
    resources = record.get("user_selected_resources", [])
    if isinstance(resources, list):
        for r in resources:
            if isinstance(r, dict) and r.get("resourceId") == "ALL":
                return "All Resources Selected"
    return "Specific Resource"


def extract_resource_selections(record):
    """Extract individual resource selection rows from a CHAT_LOGS record.

    Only called when query_scope == 'Specific Resource' (i.e., no resourceId=ALL).
    Returns a list of dicts with one entry per selected resource.
    """
    resources = record.get("user_selected_resources", [])
    if not isinstance(resources, list):
        return []
    rows = []
    for r in resources:
        if isinstance(r, dict) and r.get("resourceId") and r["resourceId"] != "ALL":
            rows.append({
                "event_timestamp": record.get("event_timestamp"),
                "conversation_id": record.get("conversation_id"),
                "user_arn": record.get("user_arn"),
                "resource_id": r.get("resourceId", ""),
                "resource_type": r.get("resourceType", ""),
            })
    return rows


def extract_plugins(record):
    """Extract individual plugin utilization rows from a CHAT_LOGS record.

    Returns a list of dicts with one entry per action connector used.
    """
    connectors = record.get("action_connectors", [])
    if not isinstance(connectors, list):
        return []
    rows = []
    for c in connectors:
        if isinstance(c, dict) and c.get("actionConnectorId"):
            rows.append({
                "event_timestamp": record.get("event_timestamp"),
                "conversation_id": record.get("conversation_id"),
                "user_arn": record.get("user_arn"),
                "plugin_id": c["actionConnectorId"],
            })
    return rows


def handler(event, context):
    """Parse S3 log file, extract CHAT_LOGS, AGENT_HOURS_LOGS, and FEEDBACK_LOGS.

    Also derives query_scope for each CHAT_LOGS record, extracts resource
    selections for messages scoped to specific resources, and extracts plugin
    utilization rows from action_connectors.
    """
    bucket = event["bucket"]
    key = event["key"]

    response = s3.get_object(Bucket=bucket, Key=key)
    content = gzip.decompress(response["Body"].read()).decode("utf-8")

    messages = []
    agent_hours = []
    feedback = []
    resource_selections = []
    plugins = []

    for line in content.strip().split("\n"):
        if not line:
            continue
        try:
            record = json.loads(line)
            log_type = record.get("logType")
            if log_type == "CHAT_LOGS":
                query_scope = derive_query_scope(record)
                record["query_scope"] = query_scope
                messages.append(record)
                if query_scope == "Specific Resource":
                    resource_selections.extend(extract_resource_selections(record))
                plugins.extend(extract_plugins(record))
            elif log_type == "AGENT_HOURS_LOGS":
                agent_hours.append(record)
            elif log_type == "FEEDBACK_LOGS":
                feedback.append(record)
        except json.JSONDecodeError:
            continue

    if not messages and not agent_hours and not feedback:
        return {
            "chat_count": 0,
            "agent_hours_count": 0,
            "feedback_count": 0,
            "resource_selections_count": 0,
            "plugin_count": 0,
        }

    result = {"temp_bucket": bucket, "source_key": key}

    if messages:
        chat_temp_key = f"temp/messages/{uuid.uuid4()}.json"
        body = "\n".join(json.dumps(m) for m in messages)
        s3.put_object(Bucket=bucket, Key=chat_temp_key, Body=body.encode())
        result["chat_temp_key"] = chat_temp_key

    result["chat_count"] = len(messages)

    if agent_hours:
        agent_hours_temp_key = f"temp/agent_hours/{uuid.uuid4()}.json"
        body = "\n".join(json.dumps(r) for r in agent_hours)
        s3.put_object(Bucket=bucket, Key=agent_hours_temp_key, Body=body.encode())
        result["agent_hours_temp_key"] = agent_hours_temp_key

    result["agent_hours_count"] = len(agent_hours)

    if feedback:
        feedback_temp_key = f"temp/feedback/{uuid.uuid4()}.json"
        body = "\n".join(json.dumps(r) for r in feedback)
        s3.put_object(Bucket=bucket, Key=feedback_temp_key, Body=body.encode())
        result["feedback_temp_key"] = feedback_temp_key

    result["feedback_count"] = len(feedback)

    if resource_selections:
        resource_selections_temp_key = f"temp/resource_selections/{uuid.uuid4()}.json"
        body = "\n".join(json.dumps(r) for r in resource_selections)
        s3.put_object(Bucket=bucket, Key=resource_selections_temp_key, Body=body.encode())
        result["resource_selections_temp_key"] = resource_selections_temp_key

    result["resource_selections_count"] = len(resource_selections)

    if plugins:
        plugin_temp_key = f"temp/plugins/{uuid.uuid4()}.json"
        body = "\n".join(json.dumps(r) for r in plugins)
        s3.put_object(Bucket=bucket, Key=plugin_temp_key, Body=body.encode())
        result["plugin_temp_key"] = plugin_temp_key

    result["plugin_count"] = len(plugins)

    return result
