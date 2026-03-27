import sys
import os
from unittest.mock import patch, MagicMock
from botocore.exceptions import ClientError

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/qs_describe_dataset")
)


@pytest.fixture(autouse=True)
def _use_qs_describe_dataset_index():
    """Pin sys.path so that 'index' resolves to qs_describe_dataset/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
def test_spice_dataset(mock_qs):
    """SPICE dataset: all fields populated from describe, permissions, and latest ingestion."""
    import index

    mock_qs.describe_data_set.return_value = {
        "DataSet": {
            "DataSetId": "ds-001",
            "Name": "My Dataset",
            "ImportMode": "SPICE",
            "LastUpdatedTime": "2024-01-15T10:00:00+00:00",
            "ConsumedSpiceCapacityInBytes": 1048576,
        }
    }
    mock_qs.describe_data_set_permissions.return_value = {
        "Permissions": [
            {"Principal": "arn:aws:quicksight:us-east-1:123456789012:user/default/alice"},
            {"Principal": "arn:aws:quicksight:us-east-1:123456789012:user/default/bob"},
        ]
    }
    mock_qs.list_ingestions.return_value = {
        "Ingestions": [
            {
                "IngestionId": "ing-001",
                "IngestionStatus": "COMPLETED",
                "CreatedTime": "2024-01-15T09:00:00+00:00",
                "IngestionTimeInSeconds": 42,
                "RequestSource": "MANUAL",
                "RequestType": "FULL_REFRESH",
                "RowInfo": {"RowsIngested": 5000, "RowsDropped": 10},
            }
        ]
    }

    result = index.handler(
        {"dataset_id": "ds-001", "name": "My Dataset", "import_mode": "SPICE"}, None
    )

    assert result["dataset_id"] == "ds-001"
    assert result["name"] == "My Dataset"
    assert result["import_mode"] == "SPICE"
    assert result["consumed_spice_bytes"] == 1048576
    assert result["rows_ingested"] == 5000
    assert result["rows_dropped"] == 10
    assert result["ingestion_status"] == "COMPLETED"
    assert result["refresh_time_seconds"] == 42
    assert result["request_source"] == "MANUAL"
    assert result["request_type"] == "FULL_REFRESH"
    assert result["permission_count"] == 2
    assert result["is_orphaned"] == "No"
    assert result["error_type"] == ""
    assert result["error_message"] == ""
    assert "synced_at" in result
    mock_qs.list_ingestions.assert_called_once_with(
        AwsAccountId="123456789012", DataSetId="ds-001", MaxResults=1
    )


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
def test_direct_query_dataset(mock_qs):
    """DIRECT_QUERY dataset: SPICE fields are 0, list_ingestions NOT called."""
    import index

    mock_qs.describe_data_set.return_value = {
        "DataSet": {
            "DataSetId": "ds-002",
            "Name": "DQ Dataset",
            "ImportMode": "DIRECT_QUERY",
            "LastUpdatedTime": "2024-01-10T08:00:00+00:00",
            "ConsumedSpiceCapacityInBytes": 0,
        }
    }
    mock_qs.describe_data_set_permissions.return_value = {
        "Permissions": [
            {"Principal": "arn:aws:quicksight:us-east-1:123456789012:user/default/charlie"},
        ]
    }

    result = index.handler(
        {"dataset_id": "ds-002", "name": "DQ Dataset", "import_mode": "DIRECT_QUERY"}, None
    )

    assert result["import_mode"] == "DIRECT_QUERY"
    assert result["rows_ingested"] == 0
    assert result["rows_dropped"] == 0
    assert result["ingestion_status"] == ""
    assert result["refresh_time_seconds"] == 0
    assert result["permission_count"] == 1
    assert result["is_orphaned"] == "No"
    mock_qs.list_ingestions.assert_not_called()


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
def test_orphaned_dataset(mock_qs):
    """Dataset with no permissions is_orphaned='Yes', permission_count=0."""
    import index

    mock_qs.describe_data_set.return_value = {
        "DataSet": {
            "DataSetId": "ds-003",
            "Name": "Orphaned Dataset",
            "ImportMode": "SPICE",
            "ConsumedSpiceCapacityInBytes": 0,
        }
    }
    mock_qs.describe_data_set_permissions.return_value = {"Permissions": []}
    mock_qs.list_ingestions.return_value = {"Ingestions": []}

    result = index.handler(
        {"dataset_id": "ds-003", "name": "Orphaned Dataset", "import_mode": "SPICE"}, None
    )

    assert result["permission_count"] == 0
    assert result["is_orphaned"] == "Yes"


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
def test_failed_ingestion(mock_qs):
    """Failed ingestion: error_type and error_message are populated from ErrorInfo."""
    import index

    mock_qs.describe_data_set.return_value = {
        "DataSet": {
            "DataSetId": "ds-004",
            "Name": "Failed DS",
            "ImportMode": "SPICE",
            "ConsumedSpiceCapacityInBytes": 0,
        }
    }
    mock_qs.describe_data_set_permissions.return_value = {
        "Permissions": [
            {"Principal": "arn:aws:quicksight:us-east-1:123456789012:user/default/admin"},
        ]
    }
    mock_qs.list_ingestions.return_value = {
        "Ingestions": [
            {
                "IngestionId": "ing-002",
                "IngestionStatus": "FAILED",
                "CreatedTime": "2024-01-16T12:00:00+00:00",
                "IngestionTimeInSeconds": 5,
                "RequestSource": "SCHEDULED",
                "RequestType": "INCREMENTAL_REFRESH",
                "RowInfo": {"RowsIngested": 0, "RowsDropped": 0},
                "ErrorInfo": {
                    "Type": "SPICE_TABLE_NOT_FOUND",
                    "Message": "The source table was not found.",
                },
            }
        ]
    }

    result = index.handler(
        {"dataset_id": "ds-004", "name": "Failed DS", "import_mode": "SPICE"}, None
    )

    assert result["ingestion_status"] == "FAILED"
    assert result["error_type"] == "SPICE_TABLE_NOT_FOUND"
    assert result["error_message"] == "The source table was not found."
