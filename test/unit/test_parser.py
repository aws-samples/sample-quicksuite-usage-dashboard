import sys
import os
import json
from unittest.mock import patch, call
from io import BytesIO

import pytest

from helpers import make_log_records

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/parser")
)


@pytest.fixture(autouse=True)
def _use_parser_index():
    """Pin sys.path so that 'index' resolves to parser/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.s3")
def test_parser_extracts_all_three_log_types(
    mock_s3, chat_record, agent_hours_record, feedback_record
):
    """Mixed file with CHAT_LOGS + AGENT_HOURS + FEEDBACK returns all 3 counts, temp keys, and resource_selections."""
    import index

    content = make_log_records([chat_record, agent_hours_record, feedback_record])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["chat_count"] == 1
    assert result["agent_hours_count"] == 1
    assert result["feedback_count"] == 1
    assert result["temp_bucket"] == "test-bucket"
    assert result["source_key"] == "AWSLogs/test/file.gz"
    assert "chat_temp_key" in result
    assert result["chat_temp_key"].startswith("temp/messages/")
    assert "agent_hours_temp_key" in result
    assert result["agent_hours_temp_key"].startswith("temp/agent_hours/")
    assert "feedback_temp_key" in result
    assert result["feedback_temp_key"].startswith("temp/feedback/")
    # chat_record has resourceId=ALL → no resource selections
    assert result["resource_selections_count"] == 0
    assert "resource_selections_temp_key" not in result


@patch("index.s3")
def test_parser_derives_query_scope_all_resources(mock_s3, chat_record):
    """Chat with resourceId=ALL → query_scope = 'All Resources Selected'."""
    import index

    content = make_log_records([chat_record])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["chat_count"] == 1
    # Inspect the written record
    put_calls = mock_s3.put_object.call_args_list
    chat_put = next(c for c in put_calls if "temp/messages/" in c.kwargs.get("Key", c.args[1] if len(c.args) > 1 else ""))
    # parse the body
    body_str = chat_put.kwargs.get("Body", b"").decode("utf-8")
    written_record = json.loads(body_str.strip().split("\n")[0])
    assert written_record["query_scope"] == "All Resources Selected"


@patch("index.s3")
def test_parser_derives_query_scope_specific_resource(
    mock_s3, chat_record_specific_resource
):
    """Chat with a specific UUID resource → query_scope = 'Specific Resource', resource selections extracted."""
    import index

    content = make_log_records([chat_record_specific_resource])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["chat_count"] == 1
    assert result["resource_selections_count"] == 1
    assert "resource_selections_temp_key" in result
    assert result["resource_selections_temp_key"].startswith("temp/resource_selections/")

    # Inspect query_scope in written chat record
    put_calls = mock_s3.put_object.call_args_list
    chat_put = next(
        c for c in put_calls
        if "temp/messages/" in c.kwargs.get("Key", "")
    )
    body_str = chat_put.kwargs.get("Body", b"").decode("utf-8")
    written_record = json.loads(body_str.strip().split("\n")[0])
    assert written_record["query_scope"] == "Specific Resource"


@patch("index.s3")
def test_parser_derives_query_scope_no_resources(mock_s3, chat_record_no_resources):
    """Chat with message_scope=no_resources → query_scope = 'No Resources Selected', no resource selections."""
    import index

    content = make_log_records([chat_record_no_resources])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["chat_count"] == 1
    assert result["resource_selections_count"] == 0
    assert "resource_selections_temp_key" not in result

    # Inspect query_scope
    put_calls = mock_s3.put_object.call_args_list
    chat_put = next(
        c for c in put_calls
        if "temp/messages/" in c.kwargs.get("Key", "")
    )
    body_str = chat_put.kwargs.get("Body", b"").decode("utf-8")
    written_record = json.loads(body_str.strip().split("\n")[0])
    assert written_record["query_scope"] == "No Resources Selected"


@patch("index.s3")
def test_parser_extracts_resource_selections(mock_s3, chat_record_specific_resource):
    """Specific resource chat → resource selection rows have correct fields."""
    import index

    content = make_log_records([chat_record_specific_resource])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["resource_selections_count"] == 1

    # Inspect the written resource selections record
    put_calls = mock_s3.put_object.call_args_list
    rs_put = next(
        c for c in put_calls
        if "temp/resource_selections/" in c.kwargs.get("Key", "")
    )
    body_str = rs_put.kwargs.get("Body", b"").decode("utf-8")
    row = json.loads(body_str.strip().split("\n")[0])

    assert row["event_timestamp"] == chat_record_specific_resource["event_timestamp"]
    assert row["conversation_id"] == chat_record_specific_resource["conversation_id"]
    assert row["user_arn"] == chat_record_specific_resource["user_arn"]
    assert row["resource_id"] == "9e05992c-ec34-4159-8cf7-ba9d758bf5b3"
    assert row["resource_type"] == "space"


@patch("index.s3")
def test_parser_skips_resource_extraction_for_all_resources(mock_s3, chat_record):
    """Chat with resourceId=ALL → resource_selections_count = 0, no temp key written."""
    import index

    content = make_log_records([chat_record])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["resource_selections_count"] == 0
    assert "resource_selections_temp_key" not in result
    # Only one put_object call: for chat (no resource_selections file)
    put_keys = [c.kwargs.get("Key", "") for c in mock_s3.put_object.call_args_list]
    assert not any("resource_selections" in k for k in put_keys)


@patch("index.s3")
def test_parser_returns_zero_when_no_matching_logs(mock_s3):
    """Only unknown log types → all counts 0, no temp files written."""
    import index

    unknown_record = {"logType": "UNKNOWN_TYPE", "data": "irrelevant"}
    content = make_log_records([unknown_record])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["chat_count"] == 0
    assert result["agent_hours_count"] == 0
    assert result["feedback_count"] == 0
    assert result["resource_selections_count"] == 0
    assert result["plugin_count"] == 0
    mock_s3.put_object.assert_not_called()


@patch("index.s3")
def test_parser_extracts_plugins(mock_s3, chat_record):
    """Chat with 2 action_connectors → plugin_count=2, plugin rows have correct fields."""
    import index

    content = make_log_records([chat_record])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["plugin_count"] == 2
    assert "plugin_temp_key" in result
    assert result["plugin_temp_key"].startswith("temp/plugins/")

    # Inspect the written plugin rows
    put_calls = mock_s3.put_object.call_args_list
    plugin_put = next(
        c for c in put_calls
        if "temp/plugins/" in c.kwargs.get("Key", "")
    )
    body_str = plugin_put.kwargs.get("Body", b"").decode("utf-8")
    rows = [json.loads(line) for line in body_str.strip().split("\n")]

    assert len(rows) == 2
    plugin_ids = {r["plugin_id"] for r in rows}
    assert plugin_ids == {"quicksuite-websearch", "quicksuite-documentation"}
    for row in rows:
        assert row["event_timestamp"] == chat_record["event_timestamp"]
        assert row["conversation_id"] == chat_record["conversation_id"]
        assert row["user_arn"] == chat_record["user_arn"]


@patch("index.s3")
def test_parser_skips_plugins_when_empty(mock_s3, chat_record):
    """Chat with empty action_connectors → plugin_count=0, no plugin temp key."""
    import index

    chat_record["action_connectors"] = []
    content = make_log_records([chat_record])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["plugin_count"] == 0
    assert "plugin_temp_key" not in result
    put_keys = [c.kwargs.get("Key", "") for c in mock_s3.put_object.call_args_list]
    assert not any("plugins" in k for k in put_keys)


@patch("index.s3")
def test_parser_includes_plugin_count_in_zero_return(mock_s3, feedback_record):
    """Feedback-only file → result includes plugin_count: 0."""
    import index

    content = make_log_records([feedback_record])
    mock_s3.get_object.return_value = {"Body": BytesIO(content)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"bucket": "test-bucket", "key": "AWSLogs/test/file.gz"}, None
    )

    assert result["plugin_count"] == 0
    assert "plugin_temp_key" not in result
