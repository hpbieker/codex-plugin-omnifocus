#!/usr/bin/env python3
"""Benchmark the OmniFocus AppleScript helper.

The benchmark creates temporary CodexPerf-* OmniFocus objects, exercises read,
search, detail, create, update, tag, and delete modes, then deletes everything it
created. It prints a JSON summary that is stable enough to compare across runs.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import statistics
import subprocess
import sys
import time
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_HELPER = ROOT / "scripts" / "read_omnifocus_tasks.applescript"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--helper",
        default=str(DEFAULT_HELPER),
        help="Path to read_omnifocus_tasks.applescript.",
    )
    parser.add_argument(
        "--output",
        help="Optional path to write the JSON report.",
    )
    parser.add_argument(
        "--prefix",
        default=None,
        help="Override the CodexPerf-* prefix used for temporary objects.",
    )
    parser.add_argument(
        "--compact",
        action="store_true",
        help="Print compact JSON instead of indented JSON.",
    )
    parser.add_argument(
        "--read-only",
        action="store_true",
        help="Only run read/search modes. Do not create, update, or delete OmniFocus objects.",
    )
    return parser.parse_args()


class Benchmark:
    def __init__(self, helper: Path, prefix: str) -> None:
        self.helper = helper
        self.prefix = prefix
        self.results: list[dict[str, Any]] = []
        self.created: dict[str, str] = {}

    def run(self, label: str, *args: str) -> dict[str, Any]:
        command = ["osascript", str(self.helper), *args]
        started = time.perf_counter()
        process = subprocess.run(command, text=True, capture_output=True)
        elapsed_ms = (time.perf_counter() - started) * 1000

        stdout = process.stdout.strip()
        stderr = process.stderr.strip()
        parsed: Any = None
        ok = process.returncode == 0

        if ok:
            try:
                parsed = json.loads(stdout)
            except json.JSONDecodeError as exc:
                ok = False
                stderr = append_error(stderr, f"json parse failed: {exc}; stdout={stdout[:200]!r}")

        result = self.result_record(label, args, process.returncode, elapsed_ms, ok, parsed, stderr)
        self.results.append(result)

        if not ok:
            failure = {
                "failedAt": label,
                "command": command,
                "elapsedMs": round(elapsed_ms, 1),
                "stdout": stdout[:1000],
                "stderr": stderr[:1000],
            }
            print(json.dumps(failure, ensure_ascii=False, indent=2), file=sys.stderr)
            raise SystemExit(1)

        return parsed

    def result_record(
        self,
        label: str,
        args: tuple[str, ...],
        returncode: int,
        elapsed_ms: float,
        ok: bool,
        parsed: Any,
        stderr: str,
    ) -> dict[str, Any]:
        returned: int | None = None
        response_count: Any = None
        has_more: Any = None

        if isinstance(parsed, dict):
            response_count = parsed.get("count")
            has_more = parsed.get("hasMore")
            returned = returned_item_count(parsed)
        elif isinstance(parsed, list):
            returned = len(parsed)

        return {
            "label": label,
            "mode": args[0] if args else "",
            "args": list(args),
            "ms": round(elapsed_ms, 1),
            "ok": ok,
            "rc": returncode,
            "count": response_count,
            "returned": returned,
            "hasMore": has_more,
            "err": stderr[:500],
        }

    def run_all(self, *, read_only: bool = False) -> dict[str, Any]:
        self.run_read_modes()
        if not read_only:
            self.run_write_lifecycle()
        return self.summary()

    def run_read_modes(self) -> None:
        self.run("tasks remaining limit=10", "tasks-remaining", "limit=10")
        self.run("tasks available limit=10", "tasks-available", "limit=10")
        self.run("tasks inbox limit=10", "tasks-inbox", "limit=10")
        self.run("tasks flagged limit=10", "tasks-flagged", "limit=10")
        self.run("tasks due limit=10", "tasks-due", "limit=10")
        self.run("tasks deferred limit=10", "tasks-deferred", "limit=10")
        self.run("tasks completed limit=10", "tasks-completed", "limit=10")
        self.run("projects remaining", "projects", "scope=remaining")
        self.run("projects active", "projects", "scope=active")
        self.run("projects all", "projects", "scope=all")
        self.run("folders", "folders")
        self.run("tags", "tags")
        self.run("search tasks no match limit=1", "search-tasks", "query=CodexPerf-NoMatch", "scope=all", "limit=1")
        self.run("search projects no match limit=1", "search-projects", "query=CodexPerf-NoMatch", "scope=all", "limit=1")
        self.run("search folders no match limit=1", "search-folders", "query=CodexPerf-NoMatch", "limit=1")
        self.run("search tags no match limit=1", "search-tags", "query=CodexPerf-NoMatch", "limit=1")

    def run_write_lifecycle(self) -> None:
        folder_name = f"{self.prefix} Folder"
        folder_name_2 = f"{self.prefix} Folder Updated"
        tag_name = f"{self.prefix} Tag"
        tag_name_2 = f"{self.prefix} Tag Updated"
        project_name = f"{self.prefix} Project"
        project_name_2 = f"{self.prefix} Project Updated"
        task_name = f"{self.prefix} Task"
        task_name_2 = f"{self.prefix} Task Updated"

        folder = self.run("create folder", "create-folder", f"name={folder_name}", "note=performance test temporary folder")
        self.created["folder"] = id_from(folder, "folder")
        self.run("folder detail by name", "folder-detail-by-name", folder_name)
        self.run("folder detail by id", "folder-detail", self.created["folder"])
        self.run("update folder", "update-folder", self.created["folder"], f"name={folder_name_2}", "note=performance test updated folder")
        self.run("search folders", "search-folders", f"query={self.prefix}", "limit=10")

        tag = self.run("create tag", "create-tag", f"name={tag_name}", "note=performance test temporary tag", "allowsNextAction=true")
        self.created["tag"] = id_from(tag, "tag")
        self.run("tag detail by name", "tag-detail-by-name", tag_name)
        self.run("tag detail by id", "tag-detail", self.created["tag"])
        self.run("update tag", "update-tag", self.created["tag"], f"name={tag_name_2}", "note=performance test updated tag", "allowsNextAction=false")
        self.run("search tags", "search-tags", f"query={self.prefix}", "limit=10")

        project = self.run(
            "create project",
            "create-project",
            f"name={project_name}",
            f"folder={folder_name_2}",
            f"tagName={tag_name_2}",
            "note=performance test temporary project",
            "sequential=true",
            "estimatedMinutes=5",
        )
        self.created["project"] = id_from(project, "project")
        self.run("project detail by name", "project-detail-by-name", project_name)
        self.run("project detail by id", "project-detail", self.created["project"])
        self.run("update project", "update-project", self.created["project"], f"name={project_name_2}", "note=performance test updated project", "flagged=true", "sequential=false", "estimatedMinutes=7")
        self.run("search projects", "search-projects", f"query={self.prefix}", "scope=all", "limit=10")

        task = self.run(
            "create task in project",
            "create-task",
            f"name={task_name}",
            f"project={project_name_2}",
            f"tagName={tag_name_2}",
            "note=performance test temporary task",
            "flagged=true",
            "estimatedMinutes=3",
        )
        self.created["task"] = id_from(task, "task")
        self.run("task detail by id", "task-detail", self.created["task"])
        self.run("update task", "update-task", self.created["task"], f"name={task_name_2}", "note=performance test updated task", "flagged=false", "estimatedMinutes=4")
        self.run("search tasks", "search-tasks", f"query={self.prefix}", "scope=all", "limit=10")
        self.run("tasks by tag name", "tasks-by-tag-name", tag_name_2, "scope=all", "limit=10")
        self.run("tasks by tag id", "tasks-by-tag", self.created["tag"], "scope=all", "limit=10")

        self.run("delete task", "delete-task", self.created["task"])
        self.created.pop("task", None)
        self.run("delete project", "delete-project", self.created["project"])
        self.created.pop("project", None)
        self.run("delete tag", "delete-tag", self.created["tag"])
        self.created.pop("tag", None)
        self.run("delete folder", "delete-folder", self.created["folder"])
        self.created.pop("folder", None)

    def cleanup(self) -> None:
        self.cleanup_created_ids()
        self.cleanup_prefix_matches()

    def cleanup_created_ids(self) -> None:
        for key, mode in (
            ("task", "delete-task"),
            ("project", "delete-project"),
            ("tag", "delete-tag"),
            ("folder", "delete-folder"),
        ):
            object_id = self.created.get(key)
            if not object_id:
                continue
            try:
                subprocess.run(["osascript", str(self.helper), mode, object_id], text=True, capture_output=True, timeout=30)
            except Exception:
                pass

    def cleanup_prefix_matches(self) -> None:
        for mode, collection_key, delete_mode, extra_args in (
            ("search-tasks", "tasks", "delete-task", ["scope=all", "limit=all"]),
            ("search-projects", "projects", "delete-project", ["scope=all", "limit=all"]),
            ("search-tags", "tags", "delete-tag", ["limit=all"]),
            ("search-folders", "folders", "delete-folder", ["limit=all"]),
        ):
            try:
                process = subprocess.run(
                    ["osascript", str(self.helper), mode, f"query={self.prefix}", *extra_args],
                    text=True,
                    capture_output=True,
                    timeout=60,
                )
                if process.returncode != 0:
                    continue
                parsed = json.loads(process.stdout)
            except Exception:
                continue

            for item in parsed.get(collection_key, []):
                object_id = item.get("id") if isinstance(item, dict) else None
                name = item.get("name", "") if isinstance(item, dict) else ""
                if not object_id or not isinstance(name, str) or not name.startswith(self.prefix):
                    continue
                try:
                    subprocess.run(["osascript", str(self.helper), delete_mode, object_id], text=True, capture_output=True, timeout=30)
                except Exception:
                    pass

    def summary(self) -> dict[str, Any]:
        successful = [result for result in self.results if result["ok"]]
        durations = [result["ms"] for result in successful]
        return {
            "prefix": self.prefix,
            "helper": str(self.helper),
            "totalCalls": len(self.results),
            "successes": len(successful),
            "failures": len(self.results) - len(successful),
            "elapsedMsTotal": round(sum(durations), 1),
            "medianMs": round(statistics.median(durations), 1) if durations else None,
            "slowest": sorted(successful, key=lambda result: result["ms"], reverse=True)[:10],
            "taskListModes": [
                result
                for result in self.results
                if result["label"].startswith("tasks ")
                and "detail" not in result["label"]
                and "by tag" not in result["label"]
            ],
            "results": self.results,
        }


def returned_item_count(parsed: dict[str, Any]) -> int | None:
    for key in ("tasks", "projects", "folders", "tags"):
        value = parsed.get(key)
        if isinstance(value, list):
            return len(value)

    for key in ("task", "project", "folder", "tag"):
        if key in parsed:
            return 1

    return None


def id_from(parsed: dict[str, Any], key: str) -> str:
    value = parsed.get(key)
    if isinstance(value, dict) and isinstance(value.get("id"), str):
        return value["id"]
    raise ValueError(f"Response did not include {key}.id")


def append_error(existing: str, message: str) -> str:
    if not existing:
        return message
    return f"{existing} | {message}"


def main() -> int:
    args = parse_args()
    helper = Path(args.helper).resolve()
    prefix = args.prefix or "CodexPerf-" + dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    benchmark = Benchmark(helper, prefix)

    try:
        report = benchmark.run_all(read_only=args.read_only)
    finally:
        if not args.read_only:
            benchmark.cleanup()

    indent = None if args.compact else 2
    payload = json.dumps(report, ensure_ascii=False, indent=indent)
    print(payload)

    if args.output:
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(payload + "\n", encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
