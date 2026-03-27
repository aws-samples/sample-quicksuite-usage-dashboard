import gzip
import json


def make_log_records(records):
    """Create gzip-compressed JSONL content from a list of record dicts."""
    lines = "\n".join(json.dumps(r) for r in records)
    return gzip.compress(lines.encode("utf-8"))
