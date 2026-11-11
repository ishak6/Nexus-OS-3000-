#!/usr/bin/env python3
"""Validate Nexus Harness metadata without executing imported content."""
import argparse
import json
import re
import sys
from pathlib import Path

ALLOWED = {
    "filesystem.read", "filesystem.write", "network.client",
    "device.camera", "device.microphone", "device.location",
}
TOP_KEYS = {"schema_version", "id", "name", "version", "capabilities", "execution"}
EXEC_KEYS = {"auto_execute", "sandbox_required", "privileged"}


def validate(data):
    errors = []
    if not isinstance(data, dict):
        return ["manifest root must be a JSON object"]
    extra, missing = set(data) - TOP_KEYS, TOP_KEYS - set(data)
    if extra:
        errors.append("unknown top-level keys: " + ", ".join(sorted(extra)))
    if missing:
        errors.append("missing top-level keys: " + ", ".join(sorted(missing)))
    if type(data.get("schema_version")) is not int or data["schema_version"] != 1:
        errors.append("schema_version must be integer 1")
    app_id = data.get("id")
    if not isinstance(app_id, str) or not re.fullmatch(r"[a-z][a-z0-9-]{2,62}", app_id):
        errors.append("id must match ^[a-z][a-z0-9-]{2,62}$")
    name = data.get("name")
    if not isinstance(name, str) or not name.strip() or len(name) > 80:
        errors.append("name must be non-empty and at most 80 characters")
    version = data.get("version")
    if not isinstance(version, str) or not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version):
        errors.append("version must use MAJOR.MINOR.PATCH")
    caps = data.get("capabilities")
    if not isinstance(caps, list):
        errors.append("capabilities must be an array")
    else:
        if any(not isinstance(x, str) for x in caps) or len(caps) != len(set(caps)):
            errors.append("capabilities must contain unique string values")
        for cap in caps:
            if not isinstance(cap, str) or cap not in ALLOWED:
                errors.append("unsupported capability: " + repr(cap))
    execution = data.get("execution")
    if not isinstance(execution, dict):
        errors.append("execution must be an object")
    else:
        extra, missing = set(execution) - EXEC_KEYS, EXEC_KEYS - set(execution)
        if extra:
            errors.append("unknown execution keys: " + ", ".join(sorted(extra)))
        if missing:
            errors.append("missing execution keys: " + ", ".join(sorted(missing)))
        if execution.get("auto_execute") is not False:
            errors.append("execution.auto_execute must be false")
        if execution.get("sandbox_required") is not True:
            errors.append("execution.sandbox_required must be true")
        if execution.get("privileged") is not False:
            errors.append("execution.privileged must be false")
    return errors


def main():
    parser = argparse.ArgumentParser(description="Validate a manifest; never runs its entrypoint.")
    parser.add_argument("manifest", type=Path)
    args = parser.parse_args()
    try:
        data = json.loads(args.manifest.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print("ERROR: " + str(exc), file=sys.stderr)
        return 2
    errors = validate(data)
    if errors:
        for error in errors:
            print("ERROR: " + error, file=sys.stderr)
        return 1
    print("OK: " + data["id"] + " is valid; no code was executed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
