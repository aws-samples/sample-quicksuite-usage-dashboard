import sys
import os
import json
from io import BytesIO
from unittest.mock import patch, MagicMock, call

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/user_merge")
)


@pytest.fixture(autouse=True)
def _use_user_merge_index():
    """Pin sys.path so that 'index' resolves to user_merge/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


# --- Shared test data ---

_IDC_USER = {
    "user_id": "user-001",
    "username": "alice",
    "display_name": "Alice Smith",
    "email": "alice@example.com",
    "title": "Engineer",
    "department": "Eng",
    "division": "Platform",
    "organization": "Tech",
    "cost_center": "CC-100",
    "employee_number": "EMP-001",
    "country": "US",
    "manager": "Bob Manager <bob.manager>",
}

_QS_USERS = {
    "alice": {
        "quicksight_role": "AUTHOR_PRO",
        "quicksight_email": "alice@example.com",
        "quicksight_active": True,
    }
}


def _make_s3_mock(idc_users, qs_users, temp_keys_for_cleanup=None):
    """Build a mock s3 client that returns given IDC and QS data."""
    mock_s3 = MagicMock()

    # idc_users: list of dicts (each written as individual file)
    # qs_users: dict of username -> {role, email, active}
    # temp_keys_for_cleanup: list of S3 keys to return when listing temp/

    idc_keys = [f"temp/idc_users/{u['user_id']}.json" for u in idc_users]
    if temp_keys_for_cleanup is None:
        temp_keys_for_cleanup = idc_keys + ["temp/qs_users.json"]

    def get_object_side_effect(Bucket, Key):
        if Key == "temp/qs_users.json":
            return {"Body": BytesIO(json.dumps(qs_users).encode())}
        for u in idc_users:
            if Key == f"temp/idc_users/{u['user_id']}.json":
                return {"Body": BytesIO(json.dumps(u).encode())}
        raise ValueError(f"Unexpected get_object key: {Key}")

    mock_s3.get_object.side_effect = get_object_side_effect
    mock_s3.put_object.return_value = {}
    mock_s3.delete_object.return_value = {}

    def paginate_side_effect(Bucket, Prefix):
        if Prefix == "temp/idc_users/":
            contents = [{"Key": k} for k in idc_keys]
            return iter([{"Contents": contents}]) if contents else iter([{}])
        elif Prefix == "temp/":
            contents = [{"Key": k} for k in temp_keys_for_cleanup]
            return iter([{"Contents": contents}]) if contents else iter([{}])
        return iter([{}])

    mock_paginator = MagicMock()
    mock_paginator.paginate.side_effect = paginate_side_effect
    mock_s3.get_paginator.return_value = mock_paginator

    return mock_s3


@patch("index.s3")
def test_merge_combines_idc_and_qs(mock_s3_raw, monkeypatch):
    """Merged record should contain all IDC fields plus QS role/email/active."""
    monkeypatch.setenv("BUCKET", "test-bucket")
    monkeypatch.setenv("OUTPUT_KEY", "user_attributes/users.jsonl")

    mock_s3_raw.get_object = _make_s3_mock([_IDC_USER], _QS_USERS).get_object
    mock_s3_raw.get_paginator = _make_s3_mock([_IDC_USER], _QS_USERS).get_paginator
    mock_s3_raw.put_object.return_value = {}
    mock_s3_raw.delete_object.return_value = {}

    import index

    # Rebuild with single mock
    merged_mock = _make_s3_mock([_IDC_USER], _QS_USERS)
    mock_s3_raw.get_object.side_effect = merged_mock.get_object.side_effect
    mock_s3_raw.get_paginator.return_value = merged_mock.get_paginator.return_value

    result = index.handler({"qs_list_key": "temp/qs_users.json"}, None)

    assert result["synced_users"] == 1
    assert result["from_idc"] == 1
    assert result["from_qs"] == 1

    # Parse the JSONL that was written
    put_call = mock_s3_raw.put_object.call_args.kwargs
    assert put_call["Key"] == "user_attributes/users.jsonl"
    lines = put_call["Body"].decode().strip().split("\n")
    assert len(lines) == 1
    record = json.loads(lines[0])

    # IDC fields
    assert record["username"] == "alice"
    assert record["display_name"] == "Alice Smith"
    assert record["email"] == "alice@example.com"
    assert record["department"] == "Eng"

    # QS fields
    assert record["quicksight_role"] == "AUTHOR_PRO"
    assert record["quicksight_email"] == "alice@example.com"
    assert record["quicksight_active"] is True


@pytest.mark.parametrize("qs_role,expected_license", [
    ("ADMIN_PRO", "Enterprise"),
    ("AUTHOR_PRO", "Enterprise"),
    ("READER_PRO", "Professional"),
    ("ADMIN", "Standard"),
    ("AUTHOR", "Standard"),
    ("READER", "Standard"),
])
@patch("index.s3")
def test_merge_derives_license_type(mock_s3_raw, monkeypatch, qs_role, expected_license):
    """License type should be derived from QuickSight role correctly."""
    monkeypatch.setenv("BUCKET", "test-bucket")
    monkeypatch.setenv("OUTPUT_KEY", "user_attributes/users.jsonl")

    import index

    idc_user = {**_IDC_USER, "user_id": "user-test", "username": "testuser"}
    qs_data = {"testuser": {"quicksight_role": qs_role, "quicksight_email": "t@t.com", "quicksight_active": True}}

    merged_mock = _make_s3_mock([idc_user], qs_data)
    mock_s3_raw.get_object.side_effect = merged_mock.get_object.side_effect
    mock_s3_raw.get_paginator.return_value = merged_mock.get_paginator.return_value
    mock_s3_raw.put_object.return_value = {}
    mock_s3_raw.delete_object.return_value = {}

    index.handler({"qs_list_key": "temp/qs_users.json"}, None)

    put_call = mock_s3_raw.put_object.call_args.kwargs
    record = json.loads(put_call["Body"].decode().strip())
    assert record["license_type"] == expected_license


@pytest.mark.parametrize("qs_role,expected_allotment", [
    ("ADMIN_PRO", 4.0),
    ("AUTHOR_PRO", 4.0),
    ("READER_PRO", 2.0),
    ("ADMIN", 0.0),
    ("AUTHOR", 0.0),
    ("READER", 0.0),
])
@patch("index.s3")
def test_merge_derives_allotment(mock_s3_raw, monkeypatch, qs_role, expected_allotment):
    """Agent hours allotment should be derived correctly from QS role."""
    monkeypatch.setenv("BUCKET", "test-bucket")
    monkeypatch.setenv("OUTPUT_KEY", "user_attributes/users.jsonl")

    import index

    idc_user = {**_IDC_USER, "user_id": "user-test", "username": "testuser"}
    qs_data = {"testuser": {"quicksight_role": qs_role, "quicksight_email": "t@t.com", "quicksight_active": True}}

    merged_mock = _make_s3_mock([idc_user], qs_data)
    mock_s3_raw.get_object.side_effect = merged_mock.get_object.side_effect
    mock_s3_raw.get_paginator.return_value = merged_mock.get_paginator.return_value
    mock_s3_raw.put_object.return_value = {}
    mock_s3_raw.delete_object.return_value = {}

    index.handler({"qs_list_key": "temp/qs_users.json"}, None)

    put_call = mock_s3_raw.put_object.call_args.kwargs
    record = json.loads(put_call["Body"].decode().strip())
    assert record["monthly_agent_hours_allotment"] == expected_allotment


@patch("index.s3")
def test_merge_writes_jsonl(mock_s3_raw, monkeypatch):
    """Output should be valid JSONL (one JSON object per line) with synced_at timestamp."""
    monkeypatch.setenv("BUCKET", "test-bucket")
    monkeypatch.setenv("OUTPUT_KEY", "user_attributes/users.jsonl")

    import index

    idc_users = [
        {**_IDC_USER, "user_id": "user-001", "username": "alice"},
        {**_IDC_USER, "user_id": "user-002", "username": "bob", "display_name": "Bob Jones"},
    ]
    qs_data = {
        "alice": {"quicksight_role": "AUTHOR_PRO", "quicksight_email": "alice@e.com", "quicksight_active": True},
        "bob": {"quicksight_role": "READER", "quicksight_email": "bob@e.com", "quicksight_active": True},
    }

    merged_mock = _make_s3_mock(idc_users, qs_data)
    mock_s3_raw.get_object.side_effect = merged_mock.get_object.side_effect
    mock_s3_raw.get_paginator.return_value = merged_mock.get_paginator.return_value
    mock_s3_raw.put_object.return_value = {}
    mock_s3_raw.delete_object.return_value = {}

    result = index.handler({"qs_list_key": "temp/qs_users.json"}, None)

    assert result["synced_users"] == 2

    put_call = mock_s3_raw.put_object.call_args.kwargs
    body = put_call["Body"].decode()
    lines = [l for l in body.strip().split("\n") if l]
    assert len(lines) == 2

    for line in lines:
        record = json.loads(line)
        assert "synced_at" in record
        # ISO timestamp ends with Z
        assert record["synced_at"].endswith("Z")
        # Validate it's a parseable ISO timestamp
        from datetime import datetime
        datetime.fromisoformat(record["synced_at"].replace("Z", "+00:00"))


@patch("index.s3")
def test_merge_cleans_temp(mock_s3_raw, monkeypatch):
    """All temp/ objects should be deleted after merging."""
    monkeypatch.setenv("BUCKET", "test-bucket")
    monkeypatch.setenv("OUTPUT_KEY", "user_attributes/users.jsonl")

    import index

    idc_user = {**_IDC_USER, "user_id": "user-001", "username": "alice"}
    qs_data = _QS_USERS

    temp_keys = [
        "temp/idc_user_list.json",
        "temp/idc_users/user-001.json",
        "temp/qs_users.json",
    ]

    merged_mock = _make_s3_mock([idc_user], qs_data, temp_keys_for_cleanup=temp_keys)
    mock_s3_raw.get_object.side_effect = merged_mock.get_object.side_effect
    mock_s3_raw.get_paginator.return_value = merged_mock.get_paginator.return_value
    mock_s3_raw.put_object.return_value = {}
    mock_s3_raw.delete_object.return_value = {}

    index.handler({"qs_list_key": "temp/qs_users.json"}, None)

    # All temp keys should have been deleted
    deleted_keys = {c.kwargs["Key"] for c in mock_s3_raw.delete_object.call_args_list}
    for k in temp_keys:
        assert k in deleted_keys, f"Expected {k} to be deleted"


@patch("index.s3")
def test_merge_idc_user_not_in_qs_gets_standard_license(mock_s3_raw, monkeypatch):
    """IDC users not found in QuickSight should get Standard license with 0.0 allotment."""
    monkeypatch.setenv("BUCKET", "test-bucket")
    monkeypatch.setenv("OUTPUT_KEY", "user_attributes/users.jsonl")

    import index

    idc_user = {**_IDC_USER, "username": "unknown_user"}
    qs_data = {}  # empty — no QS users

    merged_mock = _make_s3_mock([idc_user], qs_data)
    mock_s3_raw.get_object.side_effect = merged_mock.get_object.side_effect
    mock_s3_raw.get_paginator.return_value = merged_mock.get_paginator.return_value
    mock_s3_raw.put_object.return_value = {}
    mock_s3_raw.delete_object.return_value = {}

    result = index.handler({"qs_list_key": "temp/qs_users.json"}, None)

    assert result["synced_users"] == 1
    assert result["from_qs"] == 0

    put_call = mock_s3_raw.put_object.call_args.kwargs
    record = json.loads(put_call["Body"].decode().strip())
    assert record["quicksight_role"] is None
    assert record["license_type"] == "Standard"
    assert record["monthly_agent_hours_allotment"] == 0.0


# ---------------------------------------------------------------------------
# compute_user_tiers() pure function tests
# ---------------------------------------------------------------------------

_TIER_CONFIG = {
    "power_min": 300,
    "regular_min": 150,
    "casual_min": 1,
    "power_pct": 10,
    "regular_pct": 30,
    "dormant_days": 30,
    "churned_days": 60,
}

# Convenience: 'now' fixed to a known epoch ms so cutoffs are deterministic.
# 2026-03-21 00:00:00 UTC = 1742515200000 ms
_NOW_MS = 1742515200000
_DAY_MS = 86400 * 1000


def test_compute_tiers_threshold_and_percentile():
    """10 users with varying msg counts. Top 10% (1 user) with >=300 msgs → Power.
    Next 30% (3 users) with >=150 msgs → Regular. Rest → Casual."""
    from index import compute_user_tiers

    recent_ts = _NOW_MS - (10 * _DAY_MS)  # 10 days ago — active

    user_stats = [
        # 1 power user (rank 0 = top 10%)
        {"username": "power1", "msg_count": 500, "first_seen": 1000, "last_msg_ts": recent_ts},
        # 3 regular users (ranks 1-3, top 10%-40%, >=150 msgs)
        {"username": "regular1", "msg_count": 200, "first_seen": 1000, "last_msg_ts": recent_ts},
        {"username": "regular2", "msg_count": 180, "first_seen": 1000, "last_msg_ts": recent_ts},
        {"username": "regular3", "msg_count": 160, "first_seen": 1000, "last_msg_ts": recent_ts},
        # 6 casual users (ranks 4-9, >=1 msg but below regular threshold or outside regular pct)
        {"username": "casual1", "msg_count": 5, "first_seen": 1000, "last_msg_ts": recent_ts},
        {"username": "casual2", "msg_count": 5, "first_seen": 1000, "last_msg_ts": recent_ts},
        {"username": "casual3", "msg_count": 5, "first_seen": 1000, "last_msg_ts": recent_ts},
        {"username": "casual4", "msg_count": 5, "first_seen": 1000, "last_msg_ts": recent_ts},
        {"username": "casual5", "msg_count": 5, "first_seen": 1000, "last_msg_ts": recent_ts},
        {"username": "casual6", "msg_count": 5, "first_seen": 1000, "last_msg_ts": recent_ts},
    ]

    result = compute_user_tiers(user_stats, _TIER_CONFIG, now_ms=_NOW_MS)

    assert result["power1"]["user_tier"] == "Power User"
    assert result["regular1"]["user_tier"] == "Regular User"
    assert result["regular2"]["user_tier"] == "Regular User"
    assert result["regular3"]["user_tier"] == "Regular User"
    for name in ["casual1", "casual2", "casual3", "casual4", "casual5", "casual6"]:
        assert result[name]["user_tier"] == "Casual User", f"{name} should be Casual User"

    # first_seen_date should be populated for active users
    assert result["power1"]["first_seen_date"] == 1000


def test_compute_tiers_never_active():
    """User with 0 messages → 'Never Active', first_seen_date is None."""
    from index import compute_user_tiers

    user_stats = [
        {"username": "ghost", "msg_count": 0, "first_seen": None, "last_msg_ts": None},
    ]

    result = compute_user_tiers(user_stats, _TIER_CONFIG, now_ms=_NOW_MS)

    assert result["ghost"]["user_tier"] == "Never Active"
    assert result["ghost"]["first_seen_date"] is None


def test_compute_tiers_dormant():
    """User with messages but last_msg_ts older than dormant_days → 'Dormant'."""
    from index import compute_user_tiers

    # last message was 45 days ago — past dormant threshold (30d) but within churned (60d)
    dormant_ts = _NOW_MS - (45 * _DAY_MS)

    user_stats = [
        {"username": "sleeper", "msg_count": 50, "first_seen": 1000, "last_msg_ts": dormant_ts},
    ]

    result = compute_user_tiers(user_stats, _TIER_CONFIG, now_ms=_NOW_MS)

    assert result["sleeper"]["user_tier"] == "Dormant"
    assert result["sleeper"]["first_seen_date"] == 1000


def test_compute_tiers_churned():
    """User with last_msg_ts older than churned_days → 'Churned'."""
    from index import compute_user_tiers

    # last message was 90 days ago — past churned threshold (60d)
    churned_ts = _NOW_MS - (90 * _DAY_MS)

    user_stats = [
        {"username": "gone", "msg_count": 100, "first_seen": 1000, "last_msg_ts": churned_ts},
    ]

    result = compute_user_tiers(user_stats, _TIER_CONFIG, now_ms=_NOW_MS)

    assert result["gone"]["user_tier"] == "Churned"
    assert result["gone"]["first_seen_date"] == 1000


def test_compute_tiers_threshold_is_floor():
    """All 10 users have 400+ msgs. Top 10% (1 user) = Power, next 30% (3 users) = Regular,
    remaining 6 = Casual. Threshold is met by all, but percentile controls rank."""
    from index import compute_user_tiers

    recent_ts = _NOW_MS - (5 * _DAY_MS)  # 5 days ago — all active

    user_stats = [
        {"username": f"u{i:02d}", "msg_count": 400 + (10 - i), "first_seen": 1000, "last_msg_ts": recent_ts}
        for i in range(10)
    ]
    # u00 has highest count (410), u01=409, ..., u09=401

    result = compute_user_tiers(user_stats, _TIER_CONFIG, now_ms=_NOW_MS)

    # Top 10% of 10 = 1 user → Power
    assert result["u00"]["user_tier"] == "Power User"

    # Next 30% = 3 users (ranks 1-3) → Regular
    assert result["u01"]["user_tier"] == "Regular User"
    assert result["u02"]["user_tier"] == "Regular User"
    assert result["u03"]["user_tier"] == "Regular User"

    # Remaining 6 → Casual (all have 400+ but outside power+regular percentile)
    for i in range(4, 10):
        assert result[f"u{i:02d}"]["user_tier"] == "Casual User", f"u{i:02d} should be Casual User"
