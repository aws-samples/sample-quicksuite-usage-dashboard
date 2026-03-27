import sys
import os
import json
from unittest.mock import patch, MagicMock
from io import BytesIO

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/qs_collect_datasources")
)


@pytest.fixture(autouse=True)
def _use_qs_collect_datasources_index():
    """Pin sys.path so that 'index' resolves to qs_collect_datasources/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
@patch("index.s3")
def test_collects_datasources_with_mapping(mock_s3, mock_quicksight):
    """Should map RelationalTable datasource to dataset and write JSONL."""
    import index

    mock_quicksight.list_data_sources.return_value = {
        "DataSources": [
            {"DataSourceId": "ds-001", "Name": "Athena DS", "Type": "ATHENA"},
        ]
    }
    mock_quicksight.list_data_sets.return_value = {
        "DataSetSummaries": [
            {"DataSetId": "dataset-001", "Name": "Messages Dataset"},
        ]
    }
    mock_quicksight.describe_data_set.return_value = {
        "DataSet": {
            "DataSetId": "dataset-001",
            "Name": "Messages Dataset",
            "LastUpdatedTime": "2024-01-01",
            "CreatedTime": "2024-01-01",
            "PhysicalTableMap": {
                "table-1": {
                    "RelationalTable": {
                        "DataSourceArn": "arn:aws:quicksight:us-east-1:123456789012:datasource/ds-001",
                        "Schema": "default",
                        "Name": "messages",
                    }
                }
            },
        }
    }
    mock_s3.put_object.return_value = {}

    result = index.handler({"bucket": "test-bucket"}, None)

    assert result["count"] == 1
    assert result["output_key"] == "qs_metadata/datasources/data.jsonl"

    mock_s3.put_object.assert_called_once()
    call_kwargs = mock_s3.put_object.call_args[1]
    assert call_kwargs["Bucket"] == "test-bucket"
    assert call_kwargs["Key"] == "qs_metadata/datasources/data.jsonl"

    record = json.loads(call_kwargs["Body"].decode())
    assert record["datasource_id"] == "ds-001"
    assert record["datasource_name"] == "Athena DS"
    assert record["datasource_type"] == "ATHENA"
    assert record["dataset_id"] == "dataset-001"
    assert record["dataset_name"] == "Messages Dataset"


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
@patch("index.s3")
def test_handles_s3_source(mock_s3, mock_quicksight):
    """Should extract DataSourceArn from S3Source entry."""
    import index

    mock_quicksight.list_data_sources.return_value = {
        "DataSources": [
            {"DataSourceId": "ds-s3", "Name": "S3 Source", "Type": "S3"},
        ]
    }
    mock_quicksight.list_data_sets.return_value = {
        "DataSetSummaries": [
            {"DataSetId": "dataset-s3", "Name": "S3 Dataset"},
        ]
    }
    mock_quicksight.describe_data_set.return_value = {
        "DataSet": {
            "DataSetId": "dataset-s3",
            "Name": "S3 Dataset",
            "LastUpdatedTime": "2024-01-01",
            "CreatedTime": "2024-01-01",
            "PhysicalTableMap": {
                "table-1": {
                    "S3Source": {
                        "DataSourceArn": "arn:aws:quicksight:us-east-1:123456789012:datasource/ds-s3",
                        "InputColumns": [],
                    }
                }
            },
        }
    }
    mock_s3.put_object.return_value = {}

    result = index.handler({"bucket": "test-bucket"}, None)

    assert result["count"] == 1
    call_kwargs = mock_s3.put_object.call_args[1]
    record = json.loads(call_kwargs["Body"].decode())
    assert record["datasource_id"] == "ds-s3"
    assert record["datasource_type"] == "S3"


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
@patch("index.s3")
def test_empty_datasources(mock_s3, mock_quicksight):
    """Should return count=0 and not write to S3 when no datasources found."""
    import index

    mock_quicksight.list_data_sources.return_value = {"DataSources": []}
    mock_quicksight.list_data_sets.return_value = {"DataSetSummaries": []}

    result = index.handler({"bucket": "test-bucket"}, None)

    assert result["count"] == 0
    mock_s3.put_object.assert_not_called()
