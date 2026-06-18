#!/usr/bin/env python3
"""Run a read-only smoke test for the OmniFocus helper."""

from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "scripts" / "read_omnifocus_tasks.applescript"
MANIFEST = ROOT / ".codex-plugin" / "plugin.json"


CHECKS = [
    ("tasks inbox", ["tasks-inbox", "limit=1"]),
    ("tasks remaining", ["tasks-remaining", "limit=1"]),
    ("projects active", ["projects", "scope=active"]),
    ("folders", ["folders"]),
    ("tags", ["tags"]),
]


def run_helper(label: str, args: list[str]) -> dict[str, Any]:
    started = time.perf_counter()
    process = subprocess.run(["osascript", str(HELPER), *args], text=True, capture_output=True)
    elapsed_ms = round((time.perf_counter() - started) * 1000, 1)

    if process.returncode != 0:
        raise RuntimeError(f"{label} failed: {process.stderr.strip()}")

    try:
        parsed = json.loads(process.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"{label} returned invalid JSON: {exc}") from exc

    return {
        "label": label,
        "mode": args[0],
        "ms": elapsed_ms,
        "shape": response_shape(parsed),
    }


def response_shape(parsed: Any) -> str:
    if isinstance(parsed, list):
        return "list"
    if isinstance(parsed, dict):
        for key in ("tasks", "projects", "folders", "tags"):
            if key in parsed:
                return key
        return "object"
    return type(parsed).__name__


def main() -> int:
    with MANIFEST.open(encoding="utf-8") as handle:
        manifest = json.load(handle)

    results = [run_helper(label, args) for label, args in CHECKS]
    report = {
        "ok": True,
        "plugin": manifest.get("name"),
        "version": manifest.get("version"),
        "helper": str(HELPER),
        "checks": results,
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(json.dumps({"ok": False, "error": str(exc)}, ensure_ascii=False, indent=2), file=sys.stderr)
        raise SystemExit(1)
