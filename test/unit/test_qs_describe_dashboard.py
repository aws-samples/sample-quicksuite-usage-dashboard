import sys
import os
from unittest.mock import patch, MagicMock, call
from botocore.exceptions import ClientError

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/qs_describe_dashboard")
)


@pytest.fixture(autouse=True)
def _use_qs_describe_dashboard_index():
    """Pin sys.path so that 'index' resolves to qs_describe_dashboard/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
def test_dashboard_with_two_datasets(mock_qs):
    """Dashboard with 2 DataSetArns: returns list of 2 records, one per dataset."""
    import index

    mock_qs.describe_dashboard.return_value = {
        "Dashboard": {
            "DashboardId": "dash-001",
            "Name": "Sales Dashboard",
            "Version": {
                "DataSetArns": [
                    "arn:aws:quicksight:eu-west-1:123456789012:dataset/ds-aaa",
                    "arn:aws:quicksight:eu-west-1:123456789012:dataset/ds-bbb",
                ]
            },
        }
    }

    def describe_data_set_side_effect(AwsAccountId, DataSetId):
        datasets = {
            "ds-aaa": {
                "DataSet": {
                    "DataSetId": "ds-aaa",
                    "Name": "Revenue Data",
                    "LastUpdatedTime": "2024-01-15T10:00:00+00:00",
                    "CreatedTime": "2023-06-01T00:00:00+00:00",
                }
            },
            "ds-bbb": {
                "DataSet": {
                    "DataSetId": "ds-bbb",
                    "Name": "User Data",
                    "LastUpdatedTime": "2024-01-14T08:00:00+00:00",
                    "CreatedTime": "2023-07-01T00:00:00+00:00",
                }
            },
        }
        return datasets[DataSetId]

    mock_qs.describe_data_set.side_effect = describe_data_set_side_effect

    result = index.handler(
        {"dashboard_id": "dash-001", "dashboard_name": "Sales Dashboard"}, None
    )

    assert isinstance(result, list)
    assert len(result) == 2

    ids = {r["dataset_id"] for r in result}
    assert ids == {"ds-aaa", "ds-bbb"}

    for r in result:
        assert r["dashboard_id"] == "dash-001"
        assert r["dashboard_name"] == "Sales Dashboard"
        assert "dataset_name" in r
        assert "dataset_last_updated_time" in r
        assert "dataset_created_time" in r
        assert "synced_at" in r

    revenue_record = next(r for r in result if r["dataset_id"] == "ds-aaa")
    assert revenue_record["dataset_name"] == "Revenue Data"


@patch("index.account_id", "123456789012")
@patch("index.quicksight")
def test_dashboard_missing_dataset(mock_qs):
    """One describe_data_set raises ClientError: that dataset is skipped, other is returned."""
    import index

    mock_qs.describe_dashboard.return_value = {
        "Dashboard": {
            "DashboardId": "dash-002",
            "Name": "Partial Dashboard",
            "Version": {
                "DataSetArns": [
                    "arn:aws:quicksight:eu-west-1:123456789012:dataset/ds-good",
                    "arn:aws:quicksight:eu-west-1:123456789012:dataset/ds-deleted",
                ]
            },
        }
    }

    def describe_data_set_side_effect(AwsAccountId, DataSetId):
        if DataSetId == "ds-deleted":
            raise ClientError(
                {"Error": {"Code": "ResourceNotFoundException", "Message": "Dataset not found"}},
                "DescribeDataSet",
            )
        return {
            "DataSet": {
                "DataSetId": "ds-good",
                "Name": "Good Dataset",
                "LastUpdatedTime": "2024-01-15T10:00:00+00:00",
                "CreatedTime": "2023-06-01T00:00:00+00:00",
            }
        }

    mock_qs.describe_data_set.side_effect = describe_data_set_side_effect

    result = index.handler(
        {"dashboard_id": "dash-002", "dashboard_name": "Partial Dashboard"}, None
    )

    assert isinstance(result, list)
    assert len(result) == 1
    assert result[0]["dataset_id"] == "ds-good"
    assert result[0]["dataset_name"] == "Good Dataset"
