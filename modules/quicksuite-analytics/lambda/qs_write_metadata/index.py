import json
import boto3

s3 = boto3.client("s3")


def handler(event, context):
    bucket = event["temp_bucket"]
    output_prefix = event["output_prefix"]
    parser_temp_key = event.get("parser_temp_key")

    details = event["map_run"]["ResultWriterDetails"]
    manifest_key = details["Key"]
    manifest = json.loads(s3.get_object(Bucket=bucket, Key=manifest_key)["Body"].read().decode())

    records = []
    for file_ref in manifest.get("ResultFiles", {}).get("SUCCEEDED", []):
        items = json.loads(s3.get_object(Bucket=bucket, Key=file_ref["Key"])["Body"].read().decode())
        for item in items:
            output = item.get("Output", item)
            if isinstance(output, str):
                output = json.loads(output)
            if isinstance(output, list):
                records.extend(output)
            else:
                records.append(output)

    output_key = f"{output_prefix}data.jsonl"
    if records:
        body = "\n".join(json.dumps(r) for r in records)
        s3.put_object(Bucket=bucket, Key=output_key, Body=body.encode())

    # Cleanup: delete all objects under the manifest prefix
    prefix = manifest_key.rsplit("/", 1)[0] + "/"
    list_resp = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
    for obj in list_resp.get("Contents", []):
        s3.delete_object(Bucket=bucket, Key=obj["Key"])

    if parser_temp_key:
        s3.delete_object(Bucket=bucket, Key=parser_temp_key)

    return {"output_key": output_key, "count": len(records)}
