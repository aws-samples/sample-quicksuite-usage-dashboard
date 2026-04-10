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


def _get_extension(user, ext_name):
    """Extract a named extension dict from a DescribeUser response."""
    extensions = user.get("Extensions", {})
    return extensions.get(ext_name, {})


def handler(event, context):
    """Describe a single IDC user with enterprise extension, write to temp/idc_users/{user_id}.json."""
    user_id = event["user_id"]
    username = event["username"]

    identity_store_id = os.environ["IDENTITY_STORE_ID"]
    bucket = os.environ["BUCKET"]

    response = identitystore.describe_user(
        IdentityStoreId=identity_store_id,
        UserId=user_id,
        Extensions=["aws:identitystore:enterprise"],
    )
    user = response.get("User", response)

    # Basic fields
    display_name = user.get("DisplayName")

    emails = user.get("Emails", [])
    email = emails[0]["Value"] if emails else None

    title = user.get("Title")

    addresses = user.get("Addresses", [])
    country = addresses[0].get("Country") if addresses else None

    # Enterprise extension fields
    enterprise = _get_extension(user, "aws:identitystore:enterprise")
    department = enterprise.get("Department")
    division = enterprise.get("Division")
    organization = enterprise.get("Organization")
    cost_center = enterprise.get("CostCenter")
    employee_number = enterprise.get("EmployeeNumber")

    # Manager: stored as "Name <username>" when available
    manager_obj = enterprise.get("Manager", {})
    if manager_obj:
        manager_name = manager_obj.get("Name", "")
        manager_username = manager_obj.get("UserName", "")
        if manager_name and manager_username:
            manager = f"{manager_name} <{manager_username}>"
        elif manager_name:
            manager = manager_name
        elif manager_username:
            manager = manager_username
        else:
            manager = None
    else:
        manager = None

    user_data = {
        "user_id": user_id,
        "username": username,
        "display_name": display_name,
        "email": email,
        "title": title,
        "department": department,
        "division": division,
        "organization": organization,
        "cost_center": cost_center,
        "employee_number": employee_number,
        "country": country,
        "manager": manager,
    }

    s3_key = f"temp/idc_users/{user_id}.json"
    s3.put_object(
        Bucket=bucket,
        Key=s3_key,
        Body=json.dumps(user_data).encode("utf-8"),
        ContentType="application/json",
    )

    return {"user_id": user_id}
