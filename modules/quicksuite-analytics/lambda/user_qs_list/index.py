import json
import os

import boto3

quicksight = boto3.client("quicksight")
s3 = boto3.client("s3")
sts = boto3.client("sts")

QS_LIST_KEY = "temp/qs_users.json"


def handler(event, context):
    """Paginate quicksight:ListUsers, write username->role mapping to temp/qs_users.json."""
    bucket = os.environ["BUCKET"]
    account_id = sts.get_caller_identity()["Account"]

    paginator = quicksight.get_paginator("list_users")
    qs_users = {}
    for page in paginator.paginate(AwsAccountId=account_id, Namespace="default"):
        for user in page.get("UserList", []):
            username = user["UserName"]
            qs_users[username] = {
                "quicksight_role": user.get("Role"),
                "quicksight_email": user.get("Email"),
                "quicksight_active": user.get("Active"),
            }

    s3.put_object(
        Bucket=bucket,
        Key=QS_LIST_KEY,
        Body=json.dumps(qs_users).encode("utf-8"),
        ContentType="application/json",
    )

    return {"qs_list_key": QS_LIST_KEY, "qs_count": len(qs_users)}
