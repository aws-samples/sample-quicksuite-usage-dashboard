import json
import os
import uuid
import boto3

s3 = boto3.client("s3")
bedrock = boto3.client("bedrock-runtime", region_name=os.environ.get("BEDROCK_REGION", "us-east-1"))
dynamodb = boto3.resource("dynamodb")

_config = None


def get_config():
    global _config
    if _config is None:
        table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])
        response = table.get_item(Key={"config_id": os.environ.get("CONFIG_ID", "default")})
        _config = response["Item"]
    return _config


def _build_prompt(config, user_message, system_text_message):
    system_prompt = config.get("system_prompt", "")
    prompt_categories = config.get("prompt_categories", [])
    category_examples = config.get("category_examples", [])
    action_intents = config.get("action_intents", [])
    intent_examples = config.get("intent_examples", [])

    category_examples_str = "\n".join(
        f'Message: "{ex["message"]}" -> Category: {ex["category"]}'
        for ex in category_examples
    )
    intent_examples_str = "\n".join(
        f'Message: "{ex["message"]}" -> Intent: {ex["intent"]}'
        for ex in intent_examples
    )

    prompt = f"""{system_prompt}

## Dimension 1: Prompt Category
Categories: {", ".join(prompt_categories)}
Examples:
{category_examples_str}

## Dimension 2: Action Intent
Intents: {", ".join(action_intents)}
Examples:
{intent_examples_str}

## Dimension 3: Contains Customer Information
Answer: Yes or No

## Message to classify
User: "{user_message[:2000]}"
Assistant: "{system_text_message[:2000]}"

## Response (JSON only)
{{"prompt_category": "...", "action_intent": "...", "contains_customer_info": "..."}}"""

    return prompt


def handler(event, context):
    enabled = os.environ.get("CATEGORIZATION_ENABLED", "false") == "true"

    if not enabled:
        # Disabled mode: batch JSONL from S3
        bucket = event["temp_bucket"]
        temp_key = event["temp_key"]
        source_key = event["source_key"]

        response = s3.get_object(Bucket=bucket, Key=temp_key)
        body = response["Body"].read().decode("utf-8")

        output_lines = []
        for line in body.strip().split("\n"):
            if not line.strip():
                continue
            record = json.loads(line)
            record["prompt_category"] = "Uncategorized"
            record["action_intent"] = "Uncategorized"
            record["contains_customer_info"] = "No"
            output_lines.append(json.dumps(record))

        output_key = f"temp/categorized/{uuid.uuid4()}.json"
        s3.put_object(Bucket=bucket, Key=output_key, Body="\n".join(output_lines).encode())

        return {
            "temp_bucket": bucket,
            "temp_key": output_key,
            "source_key": source_key,
        }

    # Enabled mode: single record from Distributed Map ItemProcessor
    record = event
    config = get_config()

    user_message = record.get("user_message", "") or ""
    system_text_message = record.get("system_text_message", "") or ""

    if not user_message or user_message == "-":
        record["prompt_category"] = "Other"
        record["action_intent"] = "Other"
        record["contains_customer_info"] = "No"
        return record

    prompt = _build_prompt(config, user_message, system_text_message)

    response = bedrock.invoke_model(
        modelId=os.environ["MODEL_ID"],
        contentType="application/json",
        accept="application/json",
        body=json.dumps({
            "messages": [{"role": "user", "content": [{"text": prompt}]}],
            "inferenceConfig": {"maxTokens": 1000, "temperature": 0},
        }),
    )
    result = json.loads(response["body"].read())
    text = result["output"]["message"]["content"][0]["text"].strip()

    # Extract JSON from response — handle markdown code fences
    if text.startswith("```"):
        # Strip ```json ... ``` wrapper
        lines = text.split("\n")
        json_lines = []
        in_block = False
        for line in lines:
            if line.strip().startswith("```") and not in_block:
                in_block = True
                continue
            elif line.strip() == "```" and in_block:
                break
            elif in_block:
                json_lines.append(line)
        text = "\n".join(json_lines).strip()

    # Try to find JSON object if there's surrounding text
    if not text.startswith("{"):
        start = text.find("{")
        end = text.rfind("}") + 1
        if start >= 0 and end > start:
            text = text[start:end]

    parsed = json.loads(text)

    record["prompt_category"] = parsed.get("prompt_category", "Other")
    record["action_intent"] = parsed.get("action_intent", "Other")
    record["contains_customer_info"] = parsed.get("contains_customer_info", "No")

    return record
