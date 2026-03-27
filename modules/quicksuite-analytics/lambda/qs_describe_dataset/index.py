import json
import boto3
from datetime import datetime, timezone

quicksight = boto3.client("quicksight")
account_id = boto3.client("sts").get_caller_identity()["Account"]


def handler(event, context):
    dataset_id = event["dataset_id"]
    name = event["name"]
    import_mode = event["import_mode"]

    now_iso = datetime.now(timezone.utc).isoformat()

    ds = quicksight.describe_data_set(
        AwsAccountId=account_id, DataSetId=dataset_id
    )["DataSet"]

    permissions = quicksight.describe_data_set_permissions(
        AwsAccountId=account_id, DataSetId=dataset_id
    )["Permissions"]

    ingestion = {}
    if import_mode == "SPICE":
        ingestions = quicksight.list_ingestions(
            AwsAccountId=account_id, DataSetId=dataset_id, MaxResults=1
        ).get("Ingestions", [])
        if ingestions:
            ingestion = ingestions[0]

    return {
        "dataset_id": dataset_id,
        "name": name,
        "import_mode": import_mode,
        "last_updated_time": str(ds.get("LastUpdatedTime", "")),
        "consumed_spice_bytes": ds.get("ConsumedSpiceCapacityInBytes", 0),
        "rows_ingested": ingestion.get("RowInfo", {}).get("RowsIngested", 0),
        "rows_dropped": ingestion.get("RowInfo", {}).get("RowsDropped", 0),
        "ingestion_status": ingestion.get("IngestionStatus", ""),
        "refresh_triggered_time": str(ingestion.get("CreatedTime", "")),
        "refresh_time_seconds": ingestion.get("IngestionTimeInSeconds", 0),
        "request_source": ingestion.get("RequestSource", ""),
        "request_type": ingestion.get("RequestType", ""),
        "error_type": ingestion.get("ErrorInfo", {}).get("Type", ""),
        "error_message": ingestion.get("ErrorInfo", {}).get("Message", ""),
        "permission_count": len(permissions),
        "is_orphaned": "Yes" if len(permissions) == 0 else "No",
        "synced_at": now_iso,
    }
