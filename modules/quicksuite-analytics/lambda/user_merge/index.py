import json
import os
import time
from datetime import datetime, timedelta, timezone

import boto3

s3 = boto3.client("s3")

TIER_CONFIG = {
    "power_min": int(os.environ.get("TIER_POWER_MIN", 300)),
    "regular_min": int(os.environ.get("TIER_REGULAR_MIN", 150)),
    "casual_min": int(os.environ.get("TIER_CASUAL_MIN", 1)),
    "power_pct": int(os.environ.get("TIER_POWER_PCT", 10)),
    "regular_pct": int(os.environ.get("TIER_REGULAR_PCT", 30)),
    "dormant_days": int(os.environ.get("TIER_DORMANT_DAYS", 30)),
    "churned_days": int(os.environ.get("TIER_CHURNED_DAYS", 60)),
}


def compute_user_tiers(user_stats, config, now_ms=None):
    """Compute user tiers from message stats. Pure function, no I/O.

    user_stats: list of {username, msg_count, first_seen, last_msg_ts}
    config: tier config dict with keys:
        power_min, regular_min, casual_min, power_pct, regular_pct,
        dormant_days, churned_days
    now_ms: current epoch milliseconds (defaults to time.time() * 1000)
    Returns: dict of {username: {"user_tier": str, "first_seen_date": int|None}}
    """
    if now_ms is None:
        now_ms = int(time.time() * 1000)

    dormant_cutoff_ms = now_ms - (config["dormant_days"] * 86400 * 1000)
    churned_cutoff_ms = now_ms - (config["churned_days"] * 86400 * 1000)

    active_users = []
    result = {}

    for u in user_stats:
        username = u["username"]
        if u["msg_count"] == 0:
            result[username] = {"user_tier": "Never Active", "first_seen_date": None}
            continue
        if u["last_msg_ts"] < churned_cutoff_ms:
            result[username] = {"user_tier": "Churned", "first_seen_date": u["first_seen"]}
            continue
        if u["last_msg_ts"] < dormant_cutoff_ms:
            result[username] = {"user_tier": "Dormant", "first_seen_date": u["first_seen"]}
            continue
        active_users.append(u)

    # Sort active users by msg_count descending (O(n log n))
    active_users.sort(key=lambda x: x["msg_count"], reverse=True)
    total_active = len(active_users)

    power_cutoff = max(1, int(total_active * config["power_pct"] / 100))
    regular_cutoff = max(1, int(total_active * (config["power_pct"] + config["regular_pct"]) / 100))

    for rank, u in enumerate(active_users):
        username = u["username"]
        tier_data = {"first_seen_date": u["first_seen"]}

        if rank < power_cutoff and u["msg_count"] >= config["power_min"]:
            tier_data["user_tier"] = "Power User"
        elif rank < regular_cutoff and u["msg_count"] >= config["regular_min"]:
            tier_data["user_tier"] = "Regular User"
        else:
            tier_data["user_tier"] = "Casual User"

        result[username] = tier_data

    return result


def _query_athena_user_stats(database, output_location):
    """Query Athena for per-user message counts and recency. Returns list of user stat dicts.

    Uses exponential backoff polling (1s, 2s, 4s, 8s, max 30s, total max 120s).
    Raises on failure so caller can handle gracefully.
    """
    athena = boto3.client("athena")

    # 30-day partition filter formatted as YYYYMMDD
    cutoff_date = (datetime.now(tz=timezone.utc) - timedelta(days=30)).strftime("%Y%m%d")

    sql = f"""
SELECT regexp_extract(user_arn, '[^/]+$') AS username,
       COUNT(*) AS msg_count,
       MIN(event_timestamp) AS first_seen,
       MAX(event_timestamp) AS last_msg_ts
FROM {database}.message_enriched
WHERE year || month || day >= '{cutoff_date}'
GROUP BY 1
"""

    start_resp = athena.start_query_execution(
        QueryString=sql,
        QueryExecutionContext={"Database": database},
        ResultConfiguration={"OutputLocation": output_location},
    )
    execution_id = start_resp["QueryExecutionId"]

    # Poll with exponential backoff
    delay = 1
    elapsed = 0
    max_elapsed = 120

    while elapsed < max_elapsed:
        time.sleep(delay)
        elapsed += delay

        status_resp = athena.get_query_execution(QueryExecutionId=execution_id)
        state = status_resp["QueryExecution"]["Status"]["State"]

        if state == "SUCCEEDED":
            break
        if state in ("FAILED", "CANCELLED"):
            reason = status_resp["QueryExecution"]["Status"].get("StateChangeReason", "unknown")
            raise RuntimeError(f"Athena query {state}: {reason}")

        # Exponential backoff, cap at 30s
        delay = min(delay * 2, 30)

    else:
        raise RuntimeError(f"Athena query timed out after {max_elapsed}s")

    # Paginate results
    user_stats = []
    paginator = athena.get_paginator("get_query_results")
    first_page = True
    for page in paginator.paginate(QueryExecutionId=execution_id):
        rows = page["ResultSet"]["Rows"]
        for row in rows:
            if first_page:
                first_page = False
                continue  # skip header row
            data = row["Data"]
            username = data[0].get("VarCharValue", "")
            msg_count = int(data[1].get("VarCharValue", 0))
            first_seen = int(data[2].get("VarCharValue", 0)) if data[2].get("VarCharValue") else None
            last_msg_ts = int(data[3].get("VarCharValue", 0)) if data[3].get("VarCharValue") else None
            if username:
                user_stats.append({
                    "username": username,
                    "msg_count": msg_count,
                    "first_seen": first_seen,
                    "last_msg_ts": last_msg_ts,
                })

    return user_stats

ROLE_TO_LICENSE = {
    "ADMIN_PRO": ("Enterprise", 4.0),
    "AUTHOR_PRO": ("Enterprise", 4.0),
    "READER_PRO": ("Professional", 2.0),
    "ADMIN": ("Standard", 0.0),
    "AUTHOR": ("Standard", 0.0),
    "READER": ("Standard", 0.0),
}

DEFAULT_LICENSE = ("Standard", 0.0)


def _list_all_objects(bucket, prefix):
    """Return list of all S3 object keys under the given prefix."""
    paginator = s3.get_paginator("list_objects_v2")
    keys = []
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            keys.append(obj["Key"])
    return keys


def handler(event, context):
    """Merge IDC user describe files with QuickSight user list, write JSONL, cleanup temp."""
    bucket = os.environ["BUCKET"]
    output_key = os.environ.get("OUTPUT_KEY", "user_attributes/users.jsonl")
    qs_list_key = event["qs_list_key"]

    # Read QS user map: {username: {quicksight_role, quicksight_email, quicksight_active}}
    qs_response = s3.get_object(Bucket=bucket, Key=qs_list_key)
    qs_users = json.loads(qs_response["Body"].read().decode("utf-8"))

    # Read all IDC per-user describe files
    idc_keys = _list_all_objects(bucket, "temp/idc_users/")
    idc_users = []
    for key in idc_keys:
        resp = s3.get_object(Bucket=bucket, Key=key)
        user_data = json.loads(resp["Body"].read().decode("utf-8"))
        idc_users.append(user_data)

    synced_at = datetime.now(tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    # Merge
    merged_records = []
    for idc_user in idc_users:
        username = idc_user.get("username")
        qs_data = qs_users.get(username, {})

        qs_role = qs_data.get("quicksight_role")
        license_type, allotment = ROLE_TO_LICENSE.get(qs_role, DEFAULT_LICENSE)

        record = {
            **idc_user,
            "quicksight_role": qs_role,
            "quicksight_email": qs_data.get("quicksight_email"),
            "quicksight_active": qs_data.get("quicksight_active"),
            "license_type": license_type,
            "monthly_agent_hours_allotment": allotment,
            "synced_at": synced_at,
        }
        merged_records.append(record)

    # Compute user tiers via Athena (non-blocking — falls back to "Unknown" on error)
    database = os.environ.get("DATABASE")
    athena_output = os.environ.get("ATHENA_OUTPUT")
    tier_map = {}

    if database and athena_output:
        try:
            user_stats = _query_athena_user_stats(database, athena_output)
            tier_map = compute_user_tiers(user_stats, TIER_CONFIG)
        except Exception as exc:
            print(f"WARNING: Athena tier query failed ({exc}); setting all users to 'Unknown'")

    # Merge tier data into each user record
    for record in merged_records:
        username = record.get("username")
        tier_data = tier_map.get(username, {})
        record["user_tier"] = tier_data.get("user_tier", "Unknown")
        record["first_seen_date"] = tier_data.get("first_seen_date")

    # Write JSONL output
    jsonl_body = "\n".join(json.dumps(r) for r in merged_records)
    s3.put_object(
        Bucket=bucket,
        Key=output_key,
        Body=jsonl_body.encode("utf-8"),
        ContentType="application/x-ndjson",
    )

    # Cleanup all temp/ files
    temp_keys = _list_all_objects(bucket, "temp/")
    for key in temp_keys:
        s3.delete_object(Bucket=bucket, Key=key)

    return {
        "synced_users": len(merged_records),
        "from_idc": len(idc_users),
        "from_qs": len(qs_users),
    }
