import sys
import os
from unittest.mock import patch, MagicMock
from botocore.exceptions import ClientError

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/qs_describe_analysis")
)


@pytest.fixture(autouse=True)
def _use_qs_describe_analysis_index():
    """Pin sys.path so that 'index' resolves to qs_describe_analysis/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
def test_analysis_with_one_dataset(mock_qs):
    """Basic case: analysis with one dataset, status passed through in each record."""
    import index

    mock_qs.describe_analysis.return_value = {
        "Analysis": {
            "AnalysisId": "ana-001",
            "Name": "Revenue Analysis",
            "Status": "CREATION_SUCCESSFUL",
            "DataSetArns": [
                "arn:aws:quicksight:eu-west-1:123456789012:dataset/ds-rev",
            ],
        }
    }
    mock_qs.describe_data_set.return_value = {
        "DataSet": {
            "DataSetId": "ds-rev",
            "Name": "Revenue Data",
            "LastUpdatedTime": "2024-01-15T10:00:00+00:00",
            "CreatedTime": "2023-06-01T00:00:00+00:00",
        }
    }

    result = index.handler(
        {
            "analysis_id": "ana-001",
            "analysis_name": "Revenue Analysis",
            "status": "CREATION_SUCCESSFUL",
        },
        None,
    )

    assert isinstance(result, list)
    assert len(result) == 1
    record = result[0]
    assert record["analysis_id"] == "ana-001"
    assert record["analysis_name"] == "Revenue Analysis"
    assert record["status"] == "CREATION_SUCCESSFUL"
    assert record["dataset_id"] == "ds-rev"
    assert record["dataset_name"] == "Revenue Data"
    assert "dataset_last_updated_time" in record
    assert "dataset_created_time" in record
    assert "synced_at" in record


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
def test_analysis_deleted_status(mock_qs):
    """DELETED status analysis is still processed; deleted dataset is skipped gracefully."""
    import index

    mock_qs.describe_analysis.return_value = {
        "Analysis": {
            "AnalysisId": "ana-002",
            "Name": "Old Analysis",
            "Status": "DELETED",
            "DataSetArns": [
                "arn:aws:quicksight:eu-west-1:123456789012:dataset/ds-old",
            ],
        }
    }

    mock_qs.describe_data_set.side_effect = ClientError(
        {"Error": {"Code": "ResourceNotFoundException", "Message": "Dataset not found"}},
        "DescribeDataSet",
    )

    result = index.handler(
        {
            "analysis_id": "ana-002",
            "analysis_name": "Old Analysis",
            "status": "DELETED",
        },
        None,
    )

    # Dataset was deleted too — gracefully skipped, returns empty list
    assert isinstance(result, list)
    assert len(result) == 0
