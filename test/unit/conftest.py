import os
import pytest


@pytest.fixture(autouse=True, scope="session")
def _aws_default_region():
    """Set a default AWS region so boto3 clients can be created in unit tests without a real config."""
    os.environ.setdefault("AWS_DEFAULT_REGION", "us-east-1")


@pytest.fixture
def chat_record():
    return {
        "logType": "CHAT_LOGS",
        "event_timestamp": 1711036800000,
        "user_arn": "arn:aws:quicksight:us-east-1:123456789012:user/default/testuser",
        "user_type": "AUTHOR_PRO",
        "status_code": "success",
        "conversation_id": "conv-001",
        "system_message_id": "msg-001",
        "message_scope": "specific_resource",
        "user_selected_resources": [{"resourceId": "ALL", "resourceType": "space"}],
        "user_message_id": "umsg-001",
        "user_message": "What is our Q4 revenue?",
        "system_text_message": "Based on the data, Q4 revenue was...",
        "agent_id": "-",
        "flow_id": "-",
        "research_id": "-",
        "resource_arn": "-",
        "action_connectors": [{"actionConnectorId": "quicksuite-websearch"}, {"actionConnectorId": "quicksuite-documentation"}],
    }


@pytest.fixture
def chat_record_specific_resource():
    return {
        "logType": "CHAT_LOGS",
        "event_timestamp": 1711036800000,
        "user_arn": "arn:aws:quicksight:us-east-1:123456789012:user/default/testuser",
        "user_type": "AUTHOR_PRO",
        "status_code": "success",
        "conversation_id": "conv-001",
        "system_message_id": "msg-001",
        "message_scope": "specific_resource",
        "user_selected_resources": [
            {"resourceId": "9e05992c-ec34-4159-8cf7-ba9d758bf5b3", "resourceType": "space"},
        ],
        "user_message_id": "umsg-001",
        "user_message": "What is our Q4 revenue?",
        "system_text_message": "Based on the data, Q4 revenue was...",
        "agent_id": "-",
        "flow_id": "-",
        "research_id": "-",
        "resource_arn": "-",
    }


@pytest.fixture
def chat_record_no_resources():
    return {
        "logType": "CHAT_LOGS",
        "event_timestamp": 1711036800000,
        "user_arn": "arn:aws:quicksight:us-east-1:123456789012:user/default/testuser",
        "user_type": "AUTHOR_PRO",
        "status_code": "success",
        "conversation_id": "conv-001",
        "system_message_id": "msg-001",
        "message_scope": "no_resources",
        "user_selected_resources": [],
        "user_message_id": "umsg-001",
        "user_message": "What is our Q4 revenue?",
        "system_text_message": "Based on the data, Q4 revenue was...",
        "agent_id": "-",
        "flow_id": "-",
        "research_id": "-",
        "resource_arn": "-",
    }


@pytest.fixture
def feedback_record():
    return {
        "logType": "FEEDBACK_LOGS",
        "event_timestamp": 1711036800000,
        "user_arn": "arn:aws:quicksight:us-east-1:123456789012:user/default/testuser",
        "conversation_id": "conv-001",
        "feedback_type": "Useful",
        "feedback_reason": "-",
        "rating": "-",
    }


@pytest.fixture
def agent_hours_record():
    return {
        "logType": "AGENT_HOURS_LOGS",
        "event_timestamp": 1711036800000,
        "user_arn": "arn:aws:quicksight:us-east-1:123456789012:user/default/testuser",
        "subscription_type": "ENTERPRISE",
        "reporting_service": "RESEARCH",
        "usage_group": "Included",
        "usage_hours": 0.1667,
        "service_resource_arn": "arn:aws:quicksight::123456789012:research/abc123",
    }
