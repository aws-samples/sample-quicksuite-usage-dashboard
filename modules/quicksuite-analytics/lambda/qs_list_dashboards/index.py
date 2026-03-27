import json
import os
import uuid
import boto3

s3 = boto3.client("s3")
quicksight = boto3.client("quicksight")
account_id = boto3.client("sts").get_caller_identity()["Account"]


def handler(event, context):
    bucket = event["bucket"]
    items = []
    params = {"AwsAccountId": account_id}
    while True:
        response = quicksight.list_dashboards(**params)
        for item in response.get("DashboardSummaryList", []):
            items.append({
                "dashboard_id": item["DashboardId"],
                "dashboard_name": item["Name"],
            })
        next_token = response.get("NextToken")
        if not next_token:
            break
        params["NextToken"] = next_token

    if not items:
        return {"temp_bucket": bucket, "temp_key": "", "count": 0}

    temp_key = f"temp/qs_metadata/dashboards_list/{uuid.uuid4()}.json"
    body = "\n".join(json.dumps(item) for item in items)
    s3.put_object(Bucket=bucket, Key=temp_key, Body=body.encode())
    return {"temp_bucket": bucket, "temp_key": temp_key, "count": len(items)}
