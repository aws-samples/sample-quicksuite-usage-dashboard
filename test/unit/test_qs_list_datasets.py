import sys
import os
import json
from unittest.mock import patch, MagicMock

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/qs_list_datasets")
)


@pytest.fixture(autouse=True)
def _use_qs_list_datasets_index():
    """Pin sys.path so that 'index' resolves to qs_list_datasets/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.account_id", "123456789012")
@patch("index.s3")
@patch("index.quicksight")
def test_list_datasets_with_pagination(mock_quicksight, mock_s3):
    """Paginate 2 pages; all items collected and written as JSONL to S3."""
    import index

    mock_quicksight.list_data_sets.side_effect = [
        {
            "DataSetSummaries": [
                {"DataSetId": "ds-1", "Name": "Sales", "ImportMode": "SPICE"},
            ],
            "NextToken": "token-page2",
        },
        {
            "DataSetSummaries": [
                {"DataSetId": "ds-2", "Name": "Users", "ImportMode": "DIRECT_QUERY"},
            ],
        },
    ]
    mock_s3.put_object.return_value = {}

    result = index.handler({"bucket": "my-bucket"}, None)

    assert result["temp_bucket"] == "my-bucket"
    assert result["count"] == 2
    assert result["temp_key"].startswith("temp/qs_metadata/datasets_list/")

    assert mock_quicksight.list_data_sets.call_count == 2
    first_call = mock_quicksight.list_data_sets.call_args_list[0]
    assert first_call[1] == {"AwsAccountId": "123456789012"}
    second_call = mock_quicksight.list_data_sets.call_args_list[1]
    assert second_call[1] == {"AwsAccountId": "123456789012", "NextToken": "token-page2"}

    written_body = mock_s3.put_object.call_args[1]["Body"].decode()
    lines = [json.loads(l) for l in written_body.strip().split("\n")]
    assert len(lines) == 2
    assert lines[0] == {"dataset_id": "ds-1", "name": "Sales", "import_mode": "SPICE"}
    assert lines[1] == {"dataset_id": "ds-2", "name": "Users", "import_mode": "DIRECT_QUERY"}


@patch("index.account_id", "123456789012")
@patch("index.s3")
@patch("index.quicksight")
def test_list_datasets_empty(mock_quicksight, mock_s3):
    """Empty response returns count=0 and no S3 write."""
    import index

    mock_quicksight.list_data_sets.return_value = {"DataSetSummaries": []}

    result = index.handler({"bucket": "my-bucket"}, None)

    assert result["temp_bucket"] == "my-bucket"
    assert result["count"] == 0
    assert result["temp_key"] == ""
    mock_s3.put_object.assert_not_called()
