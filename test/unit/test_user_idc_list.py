import sys
import os
import json
from unittest.mock import patch, MagicMock

import pytest


_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/user_idc_list")
)


@pytest.fixture(autouse=True)
def _use_user_idc_list_index():
    """Pin sys.path so that 'index' resolves to user_idc_list/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.s3")
@patch("index.identitystore")
def test_user_idc_list_writes_and_returns(mock_identitystore, mock_s3, monkeypatch):
    """Should paginate ListUsers, write JSON array, and return idc_list_key + idc_count."""
    monkeypatch.setenv("IDENTITY_STORE_ID", "d-1234567890")
    monkeypatch.setenv("BUCKET", "test-bucket")

    import index

    # Set up paginator mock
    page1 = {
        "Users": [
            {"UserId": "user-001", "UserName": "alice"},
            {"UserId": "user-002", "UserName": "bob"},
        ]
    }
    page2 = {
        "Users": [
            {"UserId": "user-003", "UserName": "carol"},
        ]
    }
    mock_paginator = MagicMock()
    mock_paginator.paginate.return_value = iter([page1, page2])
    mock_identitystore.get_paginator.return_value = mock_paginator
    mock_s3.put_object.return_value = {}

    result = index.handler({}, None)

    assert result["idc_list_key"] == "temp/idc_user_list.json"
    assert result["idc_count"] == 3

    # Verify get_paginator was called correctly
    mock_identitystore.get_paginator.assert_called_once_with("list_users")
    mock_paginator.paginate.assert_called_once_with(IdentityStoreId="d-1234567890")

    # Verify put_object was called with correct key and valid JSON
    mock_s3.put_object.assert_called_once()
    call_kwargs = mock_s3.put_object.call_args.kwargs
    assert call_kwargs["Bucket"] == "test-bucket"
    assert call_kwargs["Key"] == "temp/idc_user_list.json"

    written_data = json.loads(call_kwargs["Body"].decode("utf-8"))
    assert len(written_data) == 3
    assert written_data[0] == {"user_id": "user-001", "username": "alice"}
    assert written_data[1] == {"user_id": "user-002", "username": "bob"}
    assert written_data[2] == {"user_id": "user-003", "username": "carol"}


@patch("index.s3")
@patch("index.identitystore")
def test_user_idc_list_empty(mock_identitystore, mock_s3, monkeypatch):
    """Should handle empty user list gracefully."""
    monkeypatch.setenv("IDENTITY_STORE_ID", "d-1234567890")
    monkeypatch.setenv("BUCKET", "test-bucket")

    import index

    mock_paginator = MagicMock()
    mock_paginator.paginate.return_value = iter([{"Users": []}])
    mock_identitystore.get_paginator.return_value = mock_paginator
    mock_s3.put_object.return_value = {}

    result = index.handler({}, None)

    assert result["idc_list_key"] == "temp/idc_user_list.json"
    assert result["idc_count"] == 0

    call_kwargs = mock_s3.put_object.call_args.kwargs
    written_data = json.loads(call_kwargs["Body"].decode("utf-8"))
    assert written_data == []


@patch.dict(os.environ, {"IDENTITY_STORE_ID": "d-test", "BUCKET": "test-bucket", "IDENTITY_STORE_ROLE_ARN": "arn:aws:iam::999999999999:role/test-role"})
def test_cross_account_assumes_role():
    """When IDENTITY_STORE_ROLE_ARN is set, should assume role before calling Identity Store."""
    sys.modules.pop("index", None)

    mock_sts = MagicMock()
    mock_sts.assume_role.return_value = {
        "Credentials": {
            "AccessKeyId": "AKIA_TEST",
            "SecretAccessKey": "secret_test",
            "SessionToken": "token_test",
        }
    }
    mock_idstore = MagicMock()
    mock_idstore.get_paginator.return_value.paginate.return_value = [
        {"Users": [{"UserId": "u1", "UserName": "alice"}]}
    ]
    mock_s3 = MagicMock()
    mock_s3.put_object.return_value = {}

    def client_side_effect(service, **kwargs):
        if service == "sts":
            return mock_sts
        if service == "identitystore":
            return mock_idstore
        if service == "s3":
            return mock_s3
        return MagicMock()

    with patch("boto3.client", side_effect=client_side_effect) as mock_boto3_client:
        import index

        result = index.handler({"bucket": "test-bucket"}, None)

    mock_sts.assume_role.assert_called_once_with(
        RoleArn="arn:aws:iam::999999999999:role/test-role",
        RoleSessionName="quicksuite-idc-sync"
    )
    # Verify identitystore client was created with assumed role credentials
    mock_boto3_client.assert_any_call(
        "identitystore",
        aws_access_key_id="AKIA_TEST",
        aws_secret_access_key="secret_test",
        aws_session_token="token_test",
    )
    assert result["idc_count"] == 1
