import json
import boto3
from datetime import datetime, timezone

quicksight = boto3.client("quicksight")
account_id = boto3.client("sts").get_caller_identity()["Account"]


def handler(event, context):
    dashboard_id = event["dashboard_id"]
    dashboard_name = event["dashboard_name"]

    now_iso = datetime.now(timezone.utc).isoformat()

    dashboard = quicksight.describe_dashboard(
        AwsAccountId=account_id, DashboardId=dashboard_id
    )["Dashboard"]

    dataset_arns = dashboard.get("Version", {}).get("DataSetArns", [])

    records = []
    for arn in dataset_arns:
        dataset_id = arn.split("/")[-1]
        try:
            ds = quicksight.describe_data_set(
                AwsAccountId=account_id, DataSetId=dataset_id
            )["DataSet"]
        except Exception:
            continue

        records.append({
            "dashboard_id": dashboard_id,
            "dashboard_name": dashboard_name,
            "dataset_id": dataset_id,
            "dataset_name": ds.get("Name", ""),
            "dataset_last_updated_time": str(ds.get("LastUpdatedTime", "")),
            "dataset_created_time": str(ds.get("CreatedTime", "")),
            "synced_at": now_iso,
        })

    return records
