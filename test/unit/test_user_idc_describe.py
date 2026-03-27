import sys
import os
import json
from unittest.mock import patch, MagicMock

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/user_idc_describe")
)


@pytest.fixture(autouse=True)
def _use_user_idc_describe_index():
    """Pin sys.path so that 'index' resolves to user_idc_describe/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


def _make_describe_response(user_id="user-001", username="alice"):
    """Build a mock identitystore DescribeUser response with enterprise extension fields."""
    return {
        "User": {
            "UserId": user_id,
            "UserName": username,
            "DisplayName": "Alice Smith",
            "Title": "Software Engineer",
            "Emails": [{"Value": "alice@example.com", "Type": "work", "Primary": True}],
            "Addresses": [{"Country": "US", "Primary": True}],
            "Extensions": {
                "aws:identitystore:enterprise": {
                    "Department": "Engineering",
                    "Division": "Platform",
                    "Organization": "Tech",
                    "CostCenter": "CC-100",
                    "EmployeeNumber": "EMP-001",
                    "Manager": {
                        "Name": "Bob Manager",
                        "UserName": "bob.manager",
                    },
                }
            },
        }
    }


@patch("index.s3")
@patch("index.identitystore")
def test_user_idc_describe_writes_user_data(mock_identitystore, mock_s3, monkeypatch):
    """Should call DescribeUser, extract all fields, and write to temp/idc_users/{user_id}.json."""
    monkeypatch.setenv("IDENTITY_STORE_ID", "d-1234567890")
    monkeypatch.setenv("BUCKET", "test-bucket")

    import index

    mock_identitystore.describe_user.return_value = _make_describe_response()
    mock_s3.put_object.return_value = {}

    result = index.handler({"user_id": "user-001", "username": "alice"}, None)

    assert result == {"user_id": "user-001"}

    # Verify describe_user called with enterprise extension
    mock_identitystore.describe_user.assert_called_once_with(
        IdentityStoreId="d-1234567890",
        UserId="user-001",
        Extensions=["aws:identitystore:enterprise"],
    )

    # Verify S3 write
    mock_s3.put_object.assert_called_once()
    call_kwargs = mock_s3.put_object.call_args.kwargs
    assert call_kwargs["Bucket"] == "test-bucket"
    assert call_kwargs["Key"] == "temp/idc_users/user-001.json"

    written = json.loads(call_kwargs["Body"].decode("utf-8"))
    assert written["user_id"] == "user-001"
    assert written["username"] == "alice"
    assert written["display_name"] == "Alice Smith"
    assert written["email"] == "alice@example.com"
    assert written["title"] == "Software Engineer"
    assert written["department"] == "Engineering"
    assert written["division"] == "Platform"
    assert written["organization"] == "Tech"
    assert written["cost_center"] == "CC-100"
    assert written["employee_number"] == "EMP-001"
    assert written["country"] == "US"
    assert written["manager"] == "Bob Manager <bob.manager>"


@patch("index.s3")
@patch("index.identitystore")
def test_user_idc_describe_handles_missing_fields(mock_identitystore, mock_s3, monkeypatch):
    """Should handle users with no enterprise extension or optional fields gracefully."""
    monkeypatch.setenv("IDENTITY_STORE_ID", "d-1234567890")
    monkeypatch.setenv("BUCKET", "test-bucket")

    import index

    # Minimal user with no optional fields
    mock_identitystore.describe_user.return_value = {
        "User": {
            "UserId": "user-002",
            "UserName": "bob",
            "DisplayName": "Bob Jones",
        }
    }
    mock_s3.put_object.return_value = {}

    result = index.handler({"user_id": "user-002", "username": "bob"}, None)

    assert result == {"user_id": "user-002"}

    call_kwargs = mock_s3.put_object.call_args.kwargs
    written = json.loads(call_kwargs["Body"].decode("utf-8"))
    assert written["user_id"] == "user-002"
    assert written["email"] is None
    assert written["department"] is None
    assert written["manager"] is None
    assert written["country"] is None
