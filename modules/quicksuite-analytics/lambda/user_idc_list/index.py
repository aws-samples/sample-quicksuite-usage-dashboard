import json
import os

import boto3


def get_identitystore_client():
    role_arn = os.environ.get("IDENTITY_STORE_ROLE_ARN")
    if role_arn:
        sts = boto3.client("sts")
        creds = sts.assume_role(
            RoleArn=role_arn,
            RoleSessionName="quicksuite-idc-sync"
        )["Credentials"]
        return boto3.client(
            "identitystore",
            aws_access_key_id=creds["AccessKeyId"],
            aws_secret_access_key=creds["SecretAccessKey"],
            aws_session_token=creds["SessionToken"],
        )
    return boto3.client("identitystore")


identitystore = get_identitystore_client()
s3 = boto3.client("s3")

IDC_LIST_KEY = "temp/idc_user_list.json"


def handler(event, context):
    """Paginate identitystore:ListUsers, write JSON array of {user_id, username} to temp S3 key."""
    identity_store_id = os.environ["IDENTITY_STORE_ID"]
    bucket = os.environ["BUCKET"]

    paginator = identitystore.get_paginator("list_users")
    users = []
    for page in paginator.paginate(IdentityStoreId=identity_store_id):
        for user in page.get("Users", []):
            users.append({"user_id": user["UserId"], "username": user["UserName"]})

    s3.put_object(
        Bucket=bucket,
        Key=IDC_LIST_KEY,
        Body=json.dumps(users).encode("utf-8"),
        ContentType="application/json",
    )

    return {"idc_list_key": IDC_LIST_KEY, "idc_count": len(users)}
