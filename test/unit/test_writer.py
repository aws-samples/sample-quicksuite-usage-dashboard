import sys
import os
import json
import pyarrow.parquet as pq
from unittest.mock import patch
from io import BytesIO

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/writer")
)


@pytest.fixture(autouse=True)
def _use_writer_index():
    """Pin sys.path so that 'index' resolves to writer/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.s3")
def test_writer_produces_parquet_with_prefix(mock_s3, chat_record):
    """Writer should produce a Parquet file using the output_prefix from the event."""
    import index

    input_body = (json.dumps(chat_record) + "\n").encode()
    mock_s3.get_object.return_value = {"Body": BytesIO(input_body)}
    mock_s3.put_object.return_value = {}
    mock_s3.delete_object.return_value = {}

    result = index.handler(
        {
            "temp_bucket": "test-bucket",
            "temp_key": "temp/categorized/abc.json",
            "source_key": "original.gz",
            "output_prefix": "enriched/",
        },
        None,
    )

    assert "output_key" in result
    assert result["output_key"].startswith("enriched/year=")


@patch("index.s3")
def test_writer_strips_pii_for_chat(mock_s3, chat_record):
    """Writer should strip PII fields when output_prefix is 'enriched/'."""
    import index

    input_body = (json.dumps(chat_record) + "\n").encode()
    mock_s3.get_object.return_value = {"Body": BytesIO(input_body)}
    mock_s3.put_object.return_value = {}
    mock_s3.delete_object.return_value = {}

    result = index.handler(
        {
            "temp_bucket": "test-bucket",
            "temp_key": "temp/categorized/abc.json",
            "source_key": "original.gz",
            "output_prefix": "enriched/",
        },
        None,
    )

    assert result["output_key"].startswith("enriched/year=")

    # Find the Parquet put_object call
    parquet_call = None
    for c in mock_s3.put_object.call_args_list:
        key = c.kwargs.get("Key", "")
        if key.startswith("enriched/"):
            parquet_call = c
            break
    assert parquet_call is not None

    parquet_body = parquet_call.kwargs["Body"]
    table = pq.read_table(BytesIO(parquet_body))

    # PII fields must NOT be in the output
    assert "user_message" not in table.column_names
    assert "system_text_message" not in table.column_names

    # Core fields must be present
    assert "event_timestamp" in table.column_names
    assert "user_arn" in table.column_names
    assert "status_code" in table.column_names
    assert table.num_rows == 1


@patch("index.s3")
def test_writer_keeps_all_fields_for_agent_hours(mock_s3, agent_hours_record):
    """Writer should NOT strip PII fields when output_prefix is 'enriched_agent_hours/'."""
    import index

    input_body = (json.dumps(agent_hours_record) + "\n").encode()
    mock_s3.get_object.return_value = {"Body": BytesIO(input_body)}
    mock_s3.put_object.return_value = {}
    mock_s3.delete_object.return_value = {}

    result = index.handler(
        {
            "temp_bucket": "test-bucket",
            "temp_key": "temp/agent_hours/abc.json",
            "source_key": "original.gz",
            "output_prefix": "enriched_agent_hours/",
        },
        None,
    )

    assert result["output_key"].startswith("enriched_agent_hours/year=")

    # Find the Parquet put_object call
    parquet_call = None
    for c in mock_s3.put_object.call_args_list:
        key = c.kwargs.get("Key", "")
        if key.startswith("enriched_agent_hours/"):
            parquet_call = c
            break
    assert parquet_call is not None

    parquet_body = parquet_call.kwargs["Body"]
    table = pq.read_table(BytesIO(parquet_body))

    # Agent hours core fields must be present
    assert "event_timestamp" in table.column_names
    assert "user_arn" in table.column_names
    assert "subscription_type" in table.column_names
    assert "usage_hours" in table.column_names
    assert table.num_rows == 1


@patch("index.s3")
def test_writer_cleans_up_temp_files(mock_s3, chat_record):
    """Writer should delete temp files after writing Parquet."""
    import index

    input_body = (json.dumps(chat_record) + "\n").encode()
    mock_s3.get_object.return_value = {"Body": BytesIO(input_body)}
    mock_s3.put_object.return_value = {}
    mock_s3.delete_object.return_value = {}

    index.handler(
        {
            "temp_bucket": "test-bucket",
            "temp_key": "temp/categorized/abc.json",
            "source_key": "original.gz",
            "parser_temp_key": "temp/messages/xyz.json",
        },
        None,
    )

    # Should delete both the categorizer temp and parser temp
    deleted_keys = {c.kwargs["Key"] for c in mock_s3.delete_object.call_args_list}
    assert "temp/categorized/abc.json" in deleted_keys
    assert "temp/messages/xyz.json" in deleted_keys
    # Non-map path should NOT call list_objects_v2
    mock_s3.list_objects_v2.assert_not_called()


@patch("index.s3")
def test_writer_reads_map_result_format(mock_s3, chat_record):
    """Writer should read Distributed Map ResultWriter manifest and result files."""
    import index

    # Build a record with prompt_category added (as categorizer would output)
    enriched_record = dict(chat_record)
    enriched_record["prompt_category"] = "data_analysis"

    manifest = {
        "DestinationBucket": "test-bucket",
        "ResultFiles": {
            "SUCCEEDED": [{"Key": "temp/results/exec-id/SUCCEEDED_0.json"}]
        },
    }
    # ResultWriter serializes Input/Output as JSON strings, not dicts
    result_file = [
        {
            "Input": json.dumps(chat_record),
            "Output": json.dumps(enriched_record),
            "Status": "SUCCEEDED",
        }
    ]

    def get_object_side_effect(Bucket, Key):
        if Key == "temp/results/exec-id/manifest.json":
            return {"Body": BytesIO(json.dumps(manifest).encode())}
        elif Key == "temp/results/exec-id/SUCCEEDED_0.json":
            return {"Body": BytesIO(json.dumps(result_file).encode())}
        raise ValueError(f"Unexpected key: {Key}")

    mock_s3.get_object.side_effect = get_object_side_effect
    mock_s3.list_objects_v2.return_value = {
        "Contents": [
            {"Key": "temp/results/exec-id/manifest.json"},
            {"Key": "temp/results/exec-id/SUCCEEDED_0.json"},
        ]
    }
    mock_s3.delete_object.return_value = {}
    mock_s3.delete_objects.return_value = {}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {
            "temp_bucket": "test-bucket",
            "map_run": {
                "ResultWriterDetails": {
                    "Bucket": "test-bucket",
                    "Key": "temp/results/exec-id/manifest.json",
                }
            },
            "source_key": "original.gz",
            "parser_temp_key": "temp/messages/abc.json",
            "output_prefix": "enriched/",
        },
        None,
    )

    assert result["output_key"].startswith("enriched/year=")

    # Find the Parquet put_object call
    parquet_call = None
    for c in mock_s3.put_object.call_args_list:
        key = c.kwargs.get("Key", "")
        if key.startswith("enriched/"):
            parquet_call = c
            break
    assert parquet_call is not None

    parquet_body = parquet_call.kwargs["Body"]
    table = pq.read_table(BytesIO(parquet_body))

    # prompt_category should be present from the enriched Output
    assert "prompt_category" in table.column_names
    # PII should be stripped
    assert "user_message" not in table.column_names
    assert table.num_rows == 1


@patch("index.s3")
def test_writer_empty_map_results_returns_none(mock_s3):
    """Writer should return output_key=None when SUCCEEDED list is empty."""
    import index

    manifest = {
        "DestinationBucket": "test-bucket",
        "ResultFiles": {
            "SUCCEEDED": []
        },
    }

    mock_s3.get_object.return_value = {"Body": BytesIO(json.dumps(manifest).encode())}
    mock_s3.list_objects_v2.return_value = {"Contents": []}
    mock_s3.delete_object.return_value = {}

    result = index.handler(
        {
            "temp_bucket": "test-bucket",
            "map_run": {
                "ResultWriterDetails": {
                    "Bucket": "test-bucket",
                    "Key": "temp/results/exec-id/manifest.json",
                }
            },
            "source_key": "original.gz",
            "parser_temp_key": "temp/messages/abc.json",
            "output_prefix": "enriched/",
        },
        None,
    )

    assert result["output_key"] is None
