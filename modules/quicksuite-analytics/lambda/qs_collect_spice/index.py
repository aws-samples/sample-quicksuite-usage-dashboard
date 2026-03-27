import uuid
import boto3
from datetime import datetime, timezone, timedelta
from io import BytesIO
import pyarrow as pa
import pyarrow.parquet as pq

s3 = boto3.client("s3")
cloudwatch = boto3.client("cloudwatch")


def handler(event, context):
    bucket = event["bucket"]
    now = datetime.now(timezone.utc)
    start = now - timedelta(hours=24)

    response = cloudwatch.get_metric_data(
        MetricDataQueries=[
            {
                "Id": "limit",
                "MetricStat": {
                    "Metric": {"Namespace": "AWS/QuickSight", "MetricName": "SPICECapacityLimitInMB"},
                    "Period": 3600,
                    "Stat": "Maximum",
                },
            },
            {
                "Id": "consumed",
                "MetricStat": {
                    "Metric": {"Namespace": "AWS/QuickSight", "MetricName": "SPICECapacityConsumedInMB"},
                    "Period": 3600,
                    "Stat": "Maximum",
                },
            },
        ],
        StartTime=start,
        EndTime=now,
    )

    # Parse results — align timestamps
    limit_data = {}
    consumed_data = {}
    for result in response.get("MetricDataResults", []):
        data_map = limit_data if result["Id"] == "limit" else consumed_data
        for ts, val in zip(result["Timestamps"], result["Values"]):
            data_map[ts.isoformat()] = val

    # Merge into records
    all_timestamps = sorted(set(list(limit_data.keys()) + list(consumed_data.keys())))
    if not all_timestamps:
        return {"output_key": None, "count": 0}

    timestamps = []
    limits = []
    consumeds = []
    for ts_str in all_timestamps:
        ts_dt = datetime.fromisoformat(ts_str)
        timestamps.append(int(ts_dt.timestamp() * 1000))  # epoch millis
        limits.append(limit_data.get(ts_str, 0.0))
        consumeds.append(consumed_data.get(ts_str, 0.0))

    # Write Parquet
    table = pa.table({
        "timestamp": pa.array(timestamps, type=pa.int64()),
        "spice_limit_mb": pa.array(limits, type=pa.float64()),
        "spice_consumed_mb": pa.array(consumeds, type=pa.float64()),
    })
    buf = BytesIO()
    pq.write_table(table, buf)

    dt = now
    output_key = f"qs_metadata/spice_capacity/year={dt.year:04d}/month={dt.month:02d}/day={dt.day:02d}/{uuid.uuid4()}.parquet"
    s3.put_object(Bucket=bucket, Key=output_key, Body=buf.getvalue())

    return {"output_key": output_key, "count": len(timestamps)}
