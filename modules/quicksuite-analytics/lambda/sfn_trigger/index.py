import json
import os
import boto3

sfn = boto3.client("stepfunctions")


def handler(event, context):
    """S3 event trigger — start Step Functions execution for each record."""
    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]
        sfn.start_execution(
            stateMachineArn=os.environ["STATE_MACHINE_ARN"],
            input=json.dumps({"bucket": bucket, "key": key}),
        )
    return {"processed": len(event.get("Records", []))}
