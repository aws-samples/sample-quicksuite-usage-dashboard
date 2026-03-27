import sys
import os
import json
from unittest.mock import patch, MagicMock
from io import BytesIO

import pytest

_LAMBDA_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../modules/quicksuite-analytics/lambda/categorizer")
)


@pytest.fixture(autouse=True)
def _use_categorizer_index():
    """Pin sys.path so that 'index' resolves to categorizer/index.py for this test."""
    sys.modules.pop("index", None)
    if _LAMBDA_DIR in sys.path:
        sys.path.remove(_LAMBDA_DIR)
    sys.path.insert(0, _LAMBDA_DIR)
    yield
    sys.modules.pop("index", None)


@patch.dict(os.environ, {
    "CATEGORIZATION_ENABLED": "false",
    "DYNAMODB_TABLE": "test-table",
    "CONFIG_ID": "default",
    "MODEL_ID": "test-model",
    "BEDROCK_REGION": "us-east-1",
})
@patch("index.s3")
def test_disabled_mode_injects_uncategorized(mock_s3, chat_record):
    """Disabled mode reads JSONL from S3, injects Uncategorized defaults, writes new JSONL."""
    import index

    input_body = (json.dumps(chat_record) + "\n").encode()
    mock_s3.get_object.return_value = {"Body": BytesIO(input_body)}
    mock_s3.put_object.return_value = {}

    result = index.handler(
        {"temp_bucket": "test-bucket", "temp_key": "temp/messages/abc.json", "source_key": "original.gz"},
        None,
    )

    assert "temp_key" in result
    assert result["temp_bucket"] == "test-bucket"
    assert result["source_key"] == "original.gz"
    assert result["temp_key"] != "temp/messages/abc.json"

    written_body = mock_s3.put_object.call_args[1]["Body"]
    written_lines = [json.loads(line) for line in written_body.decode().strip().split("\n")]
    assert len(written_lines) == 1
    rec = written_lines[0]
    assert rec["prompt_category"] == "Uncategorized"
    assert rec["action_intent"] == "Uncategorized"
    assert rec["contains_customer_info"] == "No"


@patch.dict(os.environ, {
    "CATEGORIZATION_ENABLED": "true",
    "DYNAMODB_TABLE": "test-table",
    "CONFIG_ID": "default",
    "MODEL_ID": "test-model",
    "BEDROCK_REGION": "us-east-1",
})
@patch("index.s3")
@patch("index.dynamodb")
@patch("index.bedrock")
def test_enabled_mode_calls_bedrock(mock_bedrock, mock_dynamodb, mock_s3, chat_record):
    """Enabled mode receives a single record, calls Bedrock, returns enriched record. No S3 I/O."""
    import index
    index._config = None

    # Mock DynamoDB config
    mock_table = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_table.get_item.return_value = {
        "Item": {
            "config_id": "default",
            "system_prompt": "Classify the following message.",
            "prompt_categories": ["DataQuery", "Other"],
            "category_examples": [{"message": "Show me revenue", "category": "DataQuery"}],
            "action_intents": ["Lookup", "Other"],
            "intent_examples": [{"message": "Show me revenue", "intent": "Lookup"}],
        }
    }

    # Mock Bedrock response
    bedrock_response_body = json.dumps({
        "prompt_category": "DataQuery",
        "action_intent": "Lookup",
        "contains_customer_info": "No",
    })
    mock_bedrock_response = {
        "body": BytesIO(json.dumps({
            "output": {
                "message": {
                    "content": [{"text": bedrock_response_body}]
                }
            }
        }).encode())
    }
    mock_bedrock.invoke_model.return_value = mock_bedrock_response

    result = index.handler(chat_record, None)

    assert result["prompt_category"] == "DataQuery"
    assert result["action_intent"] == "Lookup"
    assert result["contains_customer_info"] == "No"
    # No S3 I/O in enabled mode
    mock_s3.get_object.assert_not_called()
    mock_s3.put_object.assert_not_called()


@patch.dict(os.environ, {
    "CATEGORIZATION_ENABLED": "true",
    "DYNAMODB_TABLE": "test-table",
    "CONFIG_ID": "default",
    "MODEL_ID": "test-model",
    "BEDROCK_REGION": "us-east-1",
})
@patch("index.dynamodb")
@patch("index.bedrock")
def test_empty_message_returns_other(mock_bedrock, mock_dynamodb, chat_record):
    """Enabled mode with empty/dash user_message returns Other without calling Bedrock."""
    import index
    index._config = None

    mock_table = MagicMock()
    mock_dynamodb.Table.return_value = mock_table
    mock_table.get_item.return_value = {
        "Item": {
            "config_id": "default",
            "system_prompt": "Classify the following message.",
            "prompt_categories": ["DataQuery", "Other"],
            "category_examples": [],
            "action_intents": ["Lookup", "Other"],
            "intent_examples": [],
        }
    }

    record = dict(chat_record)
    record["user_message"] = "-"

    result = index.handler(record, None)

    assert result["prompt_category"] == "Other"
    assert result["action_intent"] == "Other"
    assert result["contains_customer_info"] == "No"
    mock_bedrock.invoke_model.assert_not_called()
