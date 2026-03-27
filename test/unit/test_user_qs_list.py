import sys
import os
import json
from unittest.mock import patch, MagicMock

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/user_qs_list")
)


@pytest.fixture(autouse=True)
def _use_user_qs_list_index():
    """Pin sys.path so that 'index' resolves to user_qs_list/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.sts")
@patch("index.s3")
@patch("index.quicksight")
def test_user_qs_list_writes_and_returns(mock_quicksight, mock_s3, mock_sts, monkeypatch):
    """Should paginate ListUsers, write username->role mapping, return qs_list_key + qs_count."""
    monkeypatch.setenv("BUCKET", "test-bucket")

    import index

    mock_sts.get_caller_identity.return_value = {"Account": "123456789012"}

    page1 = {
        "UserList": [
            {"UserName": "alice", "Role": "AUTHOR_PRO", "Email": "alice@example.com", "Active": True},
            {"UserName": "bob", "Role": "READER_PRO", "Email": "bob@example.com", "Active": True},
        ]
    }
    page2 = {
        "UserList": [
            {"UserName": "carol", "Role": "READER", "Email": "carol@example.com", "Active": False},
        ]
    }
    mock_paginator = MagicMock()
    mock_paginator.paginate.return_value = iter([page1, page2])
    mock_quicksight.get_paginator.return_value = mock_paginator
    mock_s3.put_object.return_value = {}

    result = index.handler({}, None)

    assert result["qs_list_key"] == "temp/qs_users.json"
    assert result["qs_count"] == 3

    # Verify paginator called correctly
    mock_quicksight.get_paginator.assert_called_once_with("list_users")
    mock_paginator.paginate.assert_called_once_with(
        AwsAccountId="123456789012", Namespace="default"
    )

    # Verify S3 write
    mock_s3.put_object.assert_called_once()
    call_kwargs = mock_s3.put_object.call_args.kwargs
    assert call_kwargs["Bucket"] == "test-bucket"
    assert call_kwargs["Key"] == "temp/qs_users.json"

    written = json.loads(call_kwargs["Body"].decode("utf-8"))
    assert len(written) == 3
    assert written["alice"] == {
        "quicksight_role": "AUTHOR_PRO",
        "quicksight_email": "alice@example.com",
        "quicksight_active": True,
    }
    assert written["bob"] == {
        "quicksight_role": "READER_PRO",
        "quicksight_email": "bob@example.com",
        "quicksight_active": True,
    }
    assert written["carol"] == {
        "quicksight_role": "READER",
        "quicksight_email": "carol@example.com",
        "quicksight_active": False,
    }


@patch("index.sts")
@patch("index.s3")
@patch("index.quicksight")
def test_user_qs_list_empty(mock_quicksight, mock_s3, mock_sts, monkeypatch):
    """Should handle empty user list gracefully."""
    monkeypatch.setenv("BUCKET", "test-bucket")

    import index

    mock_sts.get_caller_identity.return_value = {"Account": "123456789012"}

    mock_paginator = MagicMock()
    mock_paginator.paginate.return_value = iter([{"UserList": []}])
    mock_quicksight.get_paginator.return_value = mock_paginator
    mock_s3.put_object.return_value = {}

    result = index.handler({}, None)

    assert result["qs_list_key"] == "temp/qs_users.json"
    assert result["qs_count"] == 0
