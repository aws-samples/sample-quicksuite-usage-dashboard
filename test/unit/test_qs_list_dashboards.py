import sys
import os
import json
from unittest.mock import patch, MagicMock

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/qs_list_dashboards")
)


@pytest.fixture(autouse=True)
def _use_qs_list_dashboards_index():
    """Pin sys.path so that 'index' resolves to qs_list_dashboards/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.account_id", "123456789012")
@patch("index.s3")
@patch("index.quicksight")
def test_list_dashboards_with_pagination(mock_quicksight, mock_s3):
    """Paginate 2 pages; all items collected and written as JSONL to S3."""
    import index

    mock_quicksight.list_dashboards.side_effect = [
        {
            "DashboardSummaryList": [
                {"DashboardId": "dash-1", "Name": "Operations"},
            ],
            "NextToken": "token-page2",
        },
        {
            "DashboardSummaryList": [
                {"DashboardId": "dash-2", "Name": "Finance"},
            ],
        },
    ]
    mock_s3.put_object.return_value = {}

    result = index.handler({"bucket": "my-bucket"}, None)

    assert result["temp_bucket"] == "my-bucket"
    assert result["count"] == 2
    assert result["temp_key"].startswith("temp/qs_metadata/dashboards_list/")

    assert mock_quicksight.list_dashboards.call_count == 2
    first_call = mock_quicksight.list_dashboards.call_args_list[0]
    assert first_call[1] == {"AwsAccountId": "123456789012"}
    second_call = mock_quicksight.list_dashboards.call_args_list[1]
    assert second_call[1] == {"AwsAccountId": "123456789012", "NextToken": "token-page2"}

    written_body = mock_s3.put_object.call_args[1]["Body"].decode()
    lines = [json.loads(l) for l in written_body.strip().split("\n")]
    assert len(lines) == 2
    assert lines[0] == {"dashboard_id": "dash-1", "dashboard_name": "Operations"}
    assert lines[1] == {"dashboard_id": "dash-2", "dashboard_name": "Finance"}


@patch("index.account_id", "123456789012")
@patch("index.s3")
@patch("index.quicksight")
def test_list_dashboards_empty(mock_quicksight, mock_s3):
    """Empty response returns count=0 and no S3 write."""
    import index

    mock_quicksight.list_dashboards.return_value = {"DashboardSummaryList": []}

    result = index.handler({"bucket": "my-bucket"}, None)

    assert result["temp_bucket"] == "my-bucket"
    assert result["count"] == 0
    assert result["temp_key"] == ""
    mock_s3.put_object.assert_not_called()
