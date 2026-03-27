import json
import boto3
from datetime import datetime, timezone

quicksight = boto3.client("quicksight")
account_id = boto3.client("sts").get_caller_identity()["Account"]


def handler(event, context):
    analysis_id = event["analysis_id"]
    analysis_name = event["analysis_name"]
    status = event["status"]

    now_iso = datetime.now(timezone.utc).isoformat()

    analysis = quicksight.describe_analysis(
        AwsAccountId=account_id, AnalysisId=analysis_id
    )["Analysis"]

    dataset_arns = analysis.get("DataSetArns", [])

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
            "analysis_id": analysis_id,
            "analysis_name": analysis_name,
            "status": status,
            "dataset_id": dataset_id,
            "dataset_name": ds.get("Name", ""),
            "dataset_last_updated_time": str(ds.get("LastUpdatedTime", "")),
            "dataset_created_time": str(ds.get("CreatedTime", "")),
            "synced_at": now_iso,
        })

    return records
