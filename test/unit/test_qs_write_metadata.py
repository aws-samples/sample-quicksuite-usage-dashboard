import sys
import os
import json
from io import BytesIO
from unittest.mock import patch, call

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/qs_write_metadata")
)


@pytest.fixture(autouse=True)
def _use_qs_write_metadata_index():
    """Pin sys.path so that 'index' resolves to qs_write_metadata/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch("index.s3")
def test_normal_map_results(mock_s3):
    """Manifest with 1 SUCCEEDED file, 2 items with dict Outputs as JSON strings — writes 2 JSONL lines."""
    import index

    record1 = {"dataset_id": "ds-001", "name": "Sales Data"}
    record2 = {"dataset_id": "ds-002", "name": "Orders Data"}

    manifest = {
        "ResultFiles": {
            "SUCCEEDED": [{"Key": "temp/qs_results/exec-id/SUCCEEDED_0.json"}]
        }
    }
    result_file = [
        {"Output": json.dumps(record1), "Status": "SUCCEEDED"},
        {"Output": json.dumps(record2), "Status": "SUCCEEDED"},
    ]

    def get_object_side_effect(Bucket, Key):
        if Key == "temp/qs_results/exec-id/manifest.json":
            return {"Body": BytesIO(json.dumps(manifest).encode())}
        elif Key == "temp/qs_results/exec-id/SUCCEEDED_0.json":
            return {"Body": BytesIO(json.dumps(result_file).encode())}
        raise ValueError(f"Unexpected key: {Key}")

    mock_s3.get_object.side_effect = get_object_side_effect
    mock_s3.list_objects_v2.return_value = {
        "Contents": [
            {"Key": "temp/qs_results/exec-id/manifest.json"},
            {"Key": "temp/qs_results/exec-id/SUCCEEDED_0.json"},
        ]
    }
    mock_s3.put_object.return_value = {}
    mock_s3.delete_object.return_value = {}

    result = index.handler(
        {
            "temp_bucket": "test-bucket",
            "output_prefix": "qs_metadata/datasets/",
            "parser_temp_key": "temp/qs_metadata/datasets_list/abc.json",
            "map_run": {
                "ResultWriterDetails": {
                    "Bucket": "test-bucket",
                    "Key": "temp/qs_results/exec-id/manifest.json",
                }
            },
        },
        None,
    )

    assert result["count"] == 2
    assert result["output_key"] == "qs_metadata/datasets/data.jsonl"

    # Verify JSONL written with 2 lines
    put_call = mock_s3.put_object.call_args
    body = put_call.kwargs["Body"].decode()
    lines = body.strip().split("\n")
    assert len(lines) == 2
    assert json.loads(lines[0]) == record1
    assert json.loads(lines[1]) == record2


@patch("index.s3")
def test_list_output_flattening(mock_s3):
    """Output is a JSON-serialized list — records are flattened into 2 JSONL lines."""
    import index

    record1 = {"dataset_id": "ds-001", "analysis_id": "an-001"}
    record2 = {"dataset_id": "ds-002", "analysis_id": "an-002"}

    manifest = {
        "ResultFiles": {
            "SUCCEEDED": [{"Key": "temp/qs_results/exec-id/SUCCEEDED_0.json"}]
        }
    }
    # Output is a list (dashboard describe returns multiple dataset pairs)
    result_file = [
        {"Output": json.dumps([record1, record2]), "Status": "SUCCEEDED"},
    ]

    def get_object_side_effect(Bucket, Key):
        if Key == "temp/qs_results/exec-id/manifest.json":
            return {"Body": BytesIO(json.dumps(manifest).encode())}
        elif Key == "temp/qs_results/exec-id/SUCCEEDED_0.json":
            return {"Body": BytesIO(json.dumps(result_file).encode())}
        raise ValueError(f"Unexpected key: {Key}")

    mock_s3.get_object.side_effect = get_object_side_effect
    mock_s3.list_objects_v2.return_value = {"Contents": []}
    mock_s3.put_object.return_value = {}
    mock_s3.delete_object.return_value = {}

    result = index.handler(
        {
            "temp_bucket": "test-bucket",
            "output_prefix": "qs_metadata/datasets/",
            "map_run": {
                "ResultWriterDetails": {
                    "Bucket": "test-bucket",
                    "Key": "temp/qs_results/exec-id/manifest.json",
                }
            },
        },
        None,
    )

    assert result["count"] == 2
    put_call = mock_s3.put_object.call_args
    body = put_call.kwargs["Body"].decode()
    lines = body.strip().split("\n")
    assert len(lines) == 2
    assert json.loads(lines[0]) == record1
    assert json.loads(lines[1]) == record2


@patch("index.s3")
def test_empty_succeeded(mock_s3):
    """Manifest with empty SUCCEEDED list — no JSONL written, returns count=0."""
    import index

    manifest = {
        "ResultFiles": {
            "SUCCEEDED": []
        }
    }

    mock_s3.get_object.return_value = {"Body": BytesIO(json.dumps(manifest).encode())}
    mock_s3.list_objects_v2.return_value = {"Contents": []}
    mock_s3.delete_object.return_value = {}

    result = index.handler(
        {
            "temp_bucket": "test-bucket",
            "output_prefix": "qs_metadata/datasets/",
            "map_run": {
                "ResultWriterDetails": {
                    "Bucket": "test-bucket",
                    "Key": "temp/qs_results/exec-id/manifest.json",
                }
            },
        },
        None,
    )

    assert result["count"] == 0
    mock_s3.put_object.assert_not_called()


@patch("index.s3")
def test_cleanup(mock_s3):
    """Manifest prefix files are deleted via list_objects_v2 + delete_object, and parser_temp_key is deleted."""
    import index

    record = {"dataset_id": "ds-001"}

    manifest = {
        "ResultFiles": {
            "SUCCEEDED": [{"Key": "temp/qs_results/exec-id/SUCCEEDED_0.json"}]
        }
    }
    result_file = [
        {"Output": json.dumps(record), "Status": "SUCCEEDED"},
    ]

    def get_object_side_effect(Bucket, Key):
        if Key == "temp/qs_results/exec-id/manifest.json":
            return {"Body": BytesIO(json.dumps(manifest).encode())}
        elif Key == "temp/qs_results/exec-id/SUCCEEDED_0.json":
            return {"Body": BytesIO(json.dumps(result_file).encode())}
        raise ValueError(f"Unexpected key: {Key}")

    mock_s3.get_object.side_effect = get_object_side_effect
    mock_s3.list_objects_v2.return_value = {
        "Contents": [
            {"Key": "temp/qs_results/exec-id/manifest.json"},
            {"Key": "temp/qs_results/exec-id/SUCCEEDED_0.json"},
        ]
    }
    mock_s3.put_object.return_value = {}
    mock_s3.delete_object.return_value = {}

    index.handler(
        {
            "temp_bucket": "test-bucket",
            "output_prefix": "qs_metadata/datasets/",
            "parser_temp_key": "temp/qs_metadata/datasets_list/abc.json",
            "map_run": {
                "ResultWriterDetails": {
                    "Bucket": "test-bucket",
                    "Key": "temp/qs_results/exec-id/manifest.json",
                }
            },
        },
        None,
    )

    # list_objects_v2 called with the manifest prefix
    mock_s3.list_objects_v2.assert_called_once_with(
        Bucket="test-bucket", Prefix="temp/qs_results/exec-id/"
    )

    # delete_object called for each object in the prefix + parser_temp_key
    deleted_keys = {c.kwargs["Key"] for c in mock_s3.delete_object.call_args_list}
    assert "temp/qs_results/exec-id/manifest.json" in deleted_keys
    assert "temp/qs_results/exec-id/SUCCEEDED_0.json" in deleted_keys
    assert "temp/qs_metadata/datasets_list/abc.json" in deleted_keys
