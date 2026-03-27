import sys
import os
import json
from datetime import datetime, timezone, timedelta
from unittest.mock import patch, MagicMock
from io import BytesIO

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/qs_collect_spice")
)


@pytest.fixture(autouse=True)
def _use_qs_collect_spice_index():
    """Pin sys.path so that 'index' resolves to qs_collect_spice/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.cloudwatch")
@patch("index.s3")
def test_collects_spice_metrics(mock_s3, mock_cloudwatch):
    """Should write Parquet with correct columns when CloudWatch returns data points."""
    import index
    import pyarrow.parquet as pq

    ts1 = datetime(2024, 3, 1, 10, 0, 0, tzinfo=timezone.utc)
    ts2 = datetime(2024, 3, 1, 11, 0, 0, tzinfo=timezone.utc)

    mock_cloudwatch.get_metric_data.return_value = {
        "MetricDataResults": [
            {
                "Id": "limit",
                "Timestamps": [ts1, ts2],
                "Values": [100000.0, 100000.0],
            },
            {
                "Id": "consumed",
                "Timestamps": [ts1, ts2],
                "Values": [45000.0, 46000.0],
            },
        ]
    }
    mock_s3.put_object.return_value = {}

    result = index.handler({"bucket": "test-bucket"}, None)

    assert result["count"] == 2
    assert result["output_key"] is not None
    assert result["output_key"].startswith("qs_metadata/spice_capacity/")

    mock_s3.put_object.assert_called_once()
    call_kwargs = mock_s3.put_object.call_args[1]
    assert call_kwargs["Bucket"] == "test-bucket"

    # Verify Parquet schema and content
    buf = BytesIO(call_kwargs["Body"])
    table = pq.read_table(buf)
    assert set(table.schema.names) == {"timestamp", "spice_limit_mb", "spice_consumed_mb"}
    assert table.num_rows == 2

    # Verify timestamp values are epoch millis (int64)
    import pyarrow as pa
    assert table.schema.field("timestamp").type == pa.int64()
    assert table.schema.field("spice_limit_mb").type == pa.float64()
    assert table.schema.field("spice_consumed_mb").type == pa.float64()

    timestamps = table.column("timestamp").to_pylist()
    assert int(ts1.timestamp() * 1000) in timestamps
    assert int(ts2.timestamp() * 1000) in timestamps


@patch("index.cloudwatch")
@patch("index.s3")
def test_empty_metrics(mock_s3, mock_cloudwatch):
    """Should return output_key=None and not write to S3 when no data points."""
    import index

    mock_cloudwatch.get_metric_data.return_value = {
        "MetricDataResults": [
            {"Id": "limit", "Timestamps": [], "Values": []},
            {"Id": "consumed", "Timestamps": [], "Values": []},
        ]
    }

    result = index.handler({"bucket": "test-bucket"}, None)

    assert result["output_key"] is None
    assert result["count"] == 0
    mock_s3.put_object.assert_not_called()
