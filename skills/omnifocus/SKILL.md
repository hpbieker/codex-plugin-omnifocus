---
name: omnifocus
description: Search, read, create, update, and delete OmniFocus tasks, including inbox, flagged, due, deferred, completed, available, remaining, projects, and task details.
---

# OmniFocus

Use this skill when the user asks to search OmniFocus, read tasks from OmniFocus, inspect OmniFocus projects, summarize task lists, find due or flagged actions, extract task data from OmniFocus, create a task, update a task, delete a task, or inspect detailed metadata for a specific task.

## Requirements

- OmniFocus must be installed on the Mac where Codex is running.
- OmniFocus automation access must be allowed in macOS Privacy & Security settings if prompted.
- Use the helper script at `../../scripts/read_omnifocus_tasks.applescript` through `osascript`.
- Resolve that helper path relative to this skill directory. In an installed plugin cache, the script lives at the plugin root under `scripts/`, not inside `skills/omnifocus/`.
- OmniFocus AppleScript access requires local macOS Automation access. When running through Codex `exec_command`, request escalated execution for the `osascript` command immediately instead of first trying the sandboxed command.

## Workflow

1. Choose the narrowest task scope that satisfies the request.
2. Run the AppleScript helper with one of these modes:
   - `inbox`: incomplete inbox tasks.
   - `available`: incomplete available tasks.
   - `remaining`: all incomplete tasks.
   - `flagged`: incomplete flagged tasks.
   - `due`: incomplete tasks with a due date.
   - `deferred`: incomplete tasks with a defer date.
   - `completed`: completed tasks.
   - `projects`: incomplete projects.
   - `search query=<text> [scope=remaining] [limit=50] [detail=false]`: search tasks.
   - `detail <task-id>`: full task details.
   - `create name=<title> [note=...] [project=...] [tag=...] [due=...] [defer=...] [flagged=true] [estimatedMinutes=15]`: create a task.
   - `update <task-id> name=... note=... flagged=true completed=false due=... defer=... tag=... project=... estimatedMinutes=15`: update a task.
   - `delete <task-id>`: delete a task.
3. For ambiguous edits or deletes, identify the task first and ask for confirmation before making a destructive or hard-to-reverse change.
4. Parse the JSON output instead of scraping OmniFocus UI text.
5. Summarize only the relevant fields unless the user asks for raw JSON.
6. Keep user-facing progress terse. Do not narrate helper path discovery unless the command fails and the path must be corrected.
7. Do not report sandbox probing for OmniFocus. The integration is expected to need macOS Automation access, so go directly to the approved/escalated `osascript` path.

## Commands

```sh
osascript ../../scripts/read_omnifocus_tasks.applescript remaining
osascript ../../scripts/read_omnifocus_tasks.applescript inbox
osascript ../../scripts/read_omnifocus_tasks.applescript flagged
osascript ../../scripts/read_omnifocus_tasks.applescript due
osascript ../../scripts/read_omnifocus_tasks.applescript projects
osascript ../../scripts/read_omnifocus_tasks.applescript search query="Natalia" limit=5
osascript ../../scripts/read_omnifocus_tasks.applescript detail <task-id>
osascript ../../scripts/read_omnifocus_tasks.applescript create name="Task title" note="Optional note"
osascript ../../scripts/read_omnifocus_tasks.applescript update <task-id> flagged=true
osascript ../../scripts/read_omnifocus_tasks.applescript delete <task-id>
```

## Search

Use `search` when the user refers to a task by description, person, project, note text, tag, or partial title. This is preferred over reading all `remaining` tasks and filtering locally.

Supported options:

- `query` or `q`: text to find.
- `scope`: `remaining`, `available`, `inbox`, `flagged`, `due`, `deferred`, `completed`, or `all`.
- `limit`: maximum returned task objects; the response still includes total `count`.
- `detail`: `true` to return detailed task objects.

Search matches task id, name/title, note, project, folder, primary tag, and tags. Matching is case-insensitive.

## Write Operations

Use `create` for new inbox tasks unless the user names a project. If `project=<project name or id>` is provided, the task is created at the end of that project.

Use `update` for task changes. Supported fields:

- `name` or `title`
- `note`
- `flagged`
- `completed`
- `due`
- `defer`
- `tag`
- `project`
- `estimatedMinutes` or `estimated`

Use `delete` only when the user's intent is explicit or after confirmation. Deletion returns the deleted task's summary JSON.

Date values are parsed by macOS AppleScript in the current locale. If date parsing fails, ask the user for a clearer date/time.

## Response Style

Prefer concise updates such as:

- `Reading your OmniFocus inbox.`
- `Reading flagged tasks from OmniFocus.`
- `Reading OmniFocus projects.`
- `Searching OmniFocus tasks.`
- `Creating the OmniFocus task.`
- `Updating the OmniFocus task.`
- `Reading the OmniFocus task details.`

Avoid verbose implementation narration such as:

- explaining that the helper is AppleScript unless relevant to an error
- saying that UI scraping is being avoided
- describing path lookup attempts
- first announcing a sandbox failure before retrying with macOS Automation access

For a simple inbox request, the final answer should be direct:

```text
Your OmniFocus inbox has 1 incomplete item:

- Se på OKR-fil
  Note: Product OKRs - Q326.xlsx
```

## Output Shape

Task modes return JSON like:

```json
[
  {
    "id": "omnifocus-task-id",
    "name": "Task name",
    "project": "Project name",
    "folder": "Folder name",
    "context": "Tag name",
    "flagged": false,
    "completed": false,
    "due": "2026-06-09 12:00:00",
    "defer": "",
    "estimatedMinutes": 15,
    "note": "Optional note"
  }
]
```

Project mode returns JSON like:

```json
[
  {
    "id": "omnifocus-project-id",
    "name": "Project name",
    "folder": "Folder name",
    "status": "active",
    "completed": false,
    "due": "",
    "defer": "",
    "note": "Optional note"
  }
]
```

Detail mode returns the task shape plus extra fields:

```json
{
  "id": "omnifocus-task-id",
  "name": "Task name",
  "blocked": false,
  "next": true,
  "inInbox": false,
  "dropped": false,
  "effectivelyCompleted": false,
  "effectivelyDropped": false,
  "created": "2026-06-09 12:00:00",
  "modified": "2026-06-09 12:10:00",
  "completedDate": "",
  "effectiveDue": "",
  "effectiveDefer": "",
  "parent": "",
  "childCount": 0,
  "tags": ["Tag name"]
}
```

Search mode returns:

```json
{
  "query": "Natalia",
  "scope": "remaining",
  "count": 1,
  "limit": 5,
  "tasks": []
}
```

## Notes

- If OmniFocus is closed, the script may launch it.
- If macOS blocks automation, tell the user to allow the host app to control OmniFocus.
- Prefer `remaining` when the user asks broadly for "oppgaver".
