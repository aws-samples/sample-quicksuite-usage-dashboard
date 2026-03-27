import json
import uuid
from datetime import datetime, timezone
from io import BytesIO

import boto3
import pyarrow as pa
import pyarrow.parquet as pq

s3 = boto3.client("s3")

PII_FIELDS = {"user_message", "system_text_message"}
COMPLEX_FIELDS = {"user_selected_resources", "action_connectors", "cited_resource", "file_attachment"}


def read_jsonl(bucket, temp_key):
    """Read JSONL records from a single S3 key."""
    response = s3.get_object(Bucket=bucket, Key=temp_key)
    body = response["Body"].read().decode("utf-8")
    records = []
    for line in body.strip().split("\n"):
        if not line:
            continue
        records.append(json.loads(line))
    return records


def read_map_results(event, bucket):
    """Read records from Distributed Map ResultWriter output (manifest + result files).

    The ResultWriter serializes each item's Output as a JSON string (not a dict),
    so we must json.loads() each Output value.
    """
    manifest_key = event["map_run"]["ResultWriterDetails"]["Key"]
    manifest_response = s3.get_object(Bucket=bucket, Key=manifest_key)
    manifest = json.loads(manifest_response["Body"].read().decode("utf-8"))

    records = []
    for file_ref in manifest.get("ResultFiles", {}).get("SUCCEEDED", []):
        result_response = s3.get_object(Bucket=bucket, Key=file_ref["Key"])
        items = json.loads(result_response["Body"].read().decode("utf-8"))
        for item in items:
            output = item.get("Output", item)
            if isinstance(output, str):
                output = json.loads(output)
            records.append(output)
    return records


def handler(event, context):
    """Read messages/records from temp S3, write Parquet to output prefix, cleanup temp."""
    bucket = event["temp_bucket"]
    source_key = event["source_key"]
    parser_temp_key = event.get("parser_temp_key")
    output_prefix = event.get("output_prefix", "enriched/")

    if "map_run" in event:
        records = read_map_results(event, bucket)
        # Cleanup: delete all objects under the manifest prefix
        manifest_key = event["map_run"]["ResultWriterDetails"]["Key"]
        manifest_prefix = manifest_key.rsplit("/", 1)[0] + "/"
        list_response = s3.list_objects_v2(Bucket=bucket, Prefix=manifest_prefix)
        objects_to_delete = [{"Key": obj["Key"]} for obj in list_response.get("Contents", [])]
        if objects_to_delete:
            s3.delete_objects(Bucket=bucket, Delete={"Objects": objects_to_delete})
    else:
        temp_key = event["temp_key"]
        records = read_jsonl(bucket, temp_key)
        # Cleanup: delete the temp JSONL key
        s3.delete_object(Bucket=bucket, Key=temp_key)

    # Cleanup: delete parser temp key if present (both paths)
    if parser_temp_key:
        s3.delete_object(Bucket=bucket, Key=parser_temp_key)

    # Strip PII and complex fields
    processed = []
    for record in records:
        record = dict(record)
        if output_prefix == "enriched/":
            for field in PII_FIELDS:
                record.pop(field, None)
        for field in COMPLEX_FIELDS:
            record.pop(field, None)
        processed.append(record)
    records = processed

    if not records:
        return {"output_key": None}

    # Extract date from first record for partition path
    # CHAT_LOGS uses milliseconds (13 digits), AGENT_HOURS_LOGS uses seconds (10 digits)
    ts = records[0].get("event_timestamp", 0)
    ts_seconds = ts / 1000 if ts > 1e12 else ts
    dt = datetime.fromtimestamp(ts_seconds, tz=timezone.utc)
    year = f"{dt.year:04d}"
    month = f"{dt.month:02d}"
    day = f"{dt.day:02d}"

    # Build PyArrow table — all remaining fields as columns
    columns = {}
    for key in records[0].keys():
        values = [r.get(key) for r in records]
        if key == "event_timestamp":
            columns[key] = pa.array(values, type=pa.int64())
        elif key == "usage_hours":
            columns[key] = pa.array(values, type=pa.float64())
        else:
            columns[key] = pa.array([str(v) if v is not None else None for v in values], type=pa.string())
    table = pa.table(columns)

    # Write Parquet to buffer
    buf = BytesIO()
    pq.write_table(table, buf)
    parquet_bytes = buf.getvalue()

    output_key = f"{output_prefix}year={year}/month={month}/day={day}/{uuid.uuid4()}.parquet"
    s3.put_object(Bucket=bucket, Key=output_key, Body=parquet_bytes)

    return {"output_key": output_key}
