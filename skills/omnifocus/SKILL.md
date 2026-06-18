---
name: omnifocus
description: Search, read, create, update, and delete OmniFocus tasks, projects, folders, and tags, including inbox, flagged, due, deferred, completed, available, remaining, project/folder/tag lists, search, and details.
---

# OmniFocus

Use this skill when the user asks to search OmniFocus, read tasks from OmniFocus, inspect OmniFocus projects, folders, or tags, summarize task lists, find due or flagged actions, extract task data from OmniFocus, create a task, project, folder, or tag, update a task, project, folder, or tag, delete a task, project, folder, or tag, or inspect detailed metadata for a specific task, project, folder, or tag.

## Requirements

- OmniFocus must be installed on the Mac where Codex is running.
- OmniFocus automation access must be allowed in macOS Privacy & Security settings if prompted.
- Use the helper script at `../../scripts/read_omnifocus_tasks.applescript` through `osascript`.
- Resolve that helper path relative to this skill directory. In an installed plugin cache, the script lives at the plugin root under `scripts/`, not inside `skills/omnifocus/`.
- OmniFocus AppleScript access requires local macOS Automation access.

## Execution Contract

Always run `osascript` through Codex `exec_command` with `sandbox_permissions=require_escalated` on the first attempt. All helper modes require macOS Automation access and must not be sandbox-probed first.

## Workflow

1. Choose the narrowest task scope that satisfies the request.
   - For general task or project searches, use the default `remaining` scope unless the user explicitly asks to search completed tasks, history, archived/dropped items, or everything.
   - Do not pass `scope=all` or `scope=completed` by default. Completed tasks are not interesting unless the user asks for them.
   - Direct task detail lookups by id (`task-detail <task-id>`) do not need scope filtering.
2. Run the AppleScript helper with one of these modes:
   Task modes:
   - `create-task name=<title> [note=...] [project=...] [tag=...] [due=...] [defer=...] [flagged=true] [estimatedMinutes=15]`: create a task.
   - `delete-task <task-id>`: delete a task.
   - `search-tasks query=<text> [scope=remaining] [limit=50] [detail=false]`: full-text search tasks. Warning: emits `[omnifocus-warning] full-text-search ...`; prefer narrower commands when possible.
   - `task-detail <task-id>`: full task details.
   - `tasks-available [limit=10|all] [detail=false]`: incomplete available tasks by effective status.
   - `tasks-by-tag <tag-id> [scope=remaining] [limit=50] [detail=false]`: list tasks with a tag by id.
   - `tasks-by-tag-name <tag-name> [scope=remaining] [limit=50] [detail=false]`: list tasks with a tag by exact name.
   - `tasks-completed [limit=10|all] [detail=false]`: completed tasks by effective status.
   - `tasks-deferred [limit=10|all] [detail=false]`: incomplete tasks with a defer date by effective status.
   - `tasks-due [limit=10|all] [detail=false]`: incomplete tasks with a due date by effective status.
   - `tasks-flagged [limit=10|all] [detail=false]`: incomplete flagged tasks by effective status.
   - `tasks-inbox [limit=10|all] [detail=false]`: incomplete inbox tasks.
   - `tasks-remaining [limit=10|all] [detail=false]`: incomplete, not dropped tasks by effective status, excluding project root tasks.
   - `update-task <task-id> name=... note=... flagged=true completed=false due=... defer=... tag=... project=... estimatedMinutes=15`: update a task.
   Project modes:
   - `create-project name=<title> [note=...] [folder=...] [tag=...] [status=active] [due=...] [defer=...] [flagged=true] [sequential=true] [estimatedMinutes=15]`: create a project.
   - `delete-project <project-id>`: delete a project by id.
   - `project-detail <project-id>`: full project details by id.
   - `project-detail-by-name <project-name>`: full project details by exact name.
   - `projects [scope=remaining]`: projects. Supported scopes are `remaining`, `active`, `on-hold`, `completed`, `dropped`, and `all`.
   - `search-projects query=<text> [scope=remaining] [limit=50] [detail=false]`: full-text search projects. Warning: emits `[omnifocus-warning] full-text-search ...`; prefer narrower commands when possible.
   - `update-project <project-id> name=... note=... completed=true status=... due=... defer=... folder=... tag=... flagged=true sequential=true estimatedMinutes=15`: update a project by id.
   Folder modes:
   - `create-folder name=<title> [note=...] [folder=...]`: create a folder.
   - `delete-folder <folder-id>`: delete a folder by id.
   - `folder-detail <folder-id>`: full folder details by id.
   - `folder-detail-by-name <folder-name>`: full folder details by exact name.
   - `folders`: list folders.
   - `search-folders query=<text> [limit=50]`: full-text search folders. Warning: emits `[omnifocus-warning] full-text-search ...`; prefer narrower commands when possible.
   - `update-folder <folder-id> name=... note=... folder=... hidden=false`: update or move a folder by id.
   Tag modes:
   - `create-tag name=<title> [note=...] [tag=...] [allowsNextAction=true]`: create a tag.
   - `delete-tag <tag-id>`: delete a tag by id.
   - `search-tags query=<text> [limit=50]`: full-text search tags. Warning: emits `[omnifocus-warning] full-text-search ...`; prefer narrower commands when possible.
   - `tag-detail <tag-id>`: full tag details by id.
   - `tag-detail-by-name <tag-name>`: full tag details by exact name.
   - `tags`: list tags.
   - `update-tag <tag-id> name=... note=... tag=... allowsNextAction=true hidden=false`: update or move a tag by id.
3. For ambiguous edits or deletes, identify the task first and ask for confirmation before making a destructive or hard-to-reverse change.
4. Parse the JSON output instead of scraping OmniFocus UI text.
5. Summarize only the relevant fields unless the user asks for raw JSON.
6. Keep user-facing progress terse. Do not narrate helper path discovery unless the command fails and the path must be corrected.
7. Do not report sandbox probing for OmniFocus. The integration is expected to need macOS Automation access, so go directly to the approved/escalated `osascript` path.

## Commands

```sh
# Tasks
osascript ../../scripts/read_omnifocus_tasks.applescript create-task name="Task title" note="Optional note"
osascript ../../scripts/read_omnifocus_tasks.applescript delete-task <task-id>
osascript ../../scripts/read_omnifocus_tasks.applescript search-tasks query="Natalia" limit=5
osascript ../../scripts/read_omnifocus_tasks.applescript task-detail <task-id>
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-available
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-by-tag <tag-id>
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-by-tag-name "Waiting"
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-completed
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-deferred
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-due
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-flagged
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-inbox
osascript ../../scripts/read_omnifocus_tasks.applescript tasks-remaining
osascript ../../scripts/read_omnifocus_tasks.applescript update-task <task-id> flagged=true

# Projects
osascript ../../scripts/read_omnifocus_tasks.applescript create-project name="Project title" note="Optional note"
osascript ../../scripts/read_omnifocus_tasks.applescript delete-project <project-id>
osascript ../../scripts/read_omnifocus_tasks.applescript project-detail <project-id>
osascript ../../scripts/read_omnifocus_tasks.applescript project-detail-by-name "Project name"
osascript ../../scripts/read_omnifocus_tasks.applescript projects
osascript ../../scripts/read_omnifocus_tasks.applescript search-projects query="Energy" detail=true
osascript ../../scripts/read_omnifocus_tasks.applescript update-project <project-id> completed=true

# Folders
osascript ../../scripts/read_omnifocus_tasks.applescript create-folder name="Folder title"
osascript ../../scripts/read_omnifocus_tasks.applescript folders
osascript ../../scripts/read_omnifocus_tasks.applescript search-folders query="Work"

# Tags
osascript ../../scripts/read_omnifocus_tasks.applescript create-tag name="Tag title"
osascript ../../scripts/read_omnifocus_tasks.applescript search-tags query="Office"
osascript ../../scripts/read_omnifocus_tasks.applescript tags
```

## Search

Use `search-tasks` when the user refers to a task by description, person, project, note text, tag, or partial title. This is preferred over reading all `remaining` tasks and filtering locally.

Default to `scope=remaining` for general searches. Use `scope=all` or `scope=completed` only when the user explicitly asks for all tasks, completed tasks, history, or an old/closed item. This scope rule does not apply to direct lookup by task id with `task-detail`.

Full-text search modes emit `[omnifocus-warning] full-text-search ...` to stderr. Treat that warning as a signal to prefer a narrower mode such as `task-detail`, `tasks-by-tag`, or `tasks-by-tag-name` when the intent allows it.

Supported options:

- `query` or `q`: text to find.
- `scope`: `remaining`, `available`, `inbox`, `flagged`, `due`, `deferred`, `completed`, or `all`.
- `limit`: maximum returned task objects; the response still includes total `count`.
- `detail`: `true` to return detailed task objects.

Search matches task id, name/title, note, project, folder, primary tag, and tags. Matching is case-insensitive.

Use `search-projects` when the user refers to a project by description, folder, note text, tag, status, or partial title. This is preferred over reading all projects and filtering locally.

Default to `scope=remaining` for project searches. Use `scope=all`, `scope=completed`, or `scope=dropped` only when the user explicitly asks for that wider set.

Supported project search options:

- `query` or `q`: text to find.
- `scope`: `remaining`, `active`, `on-hold`, `completed`, `dropped`, or `all`.
- `limit`: maximum returned project objects; the response still includes total `count`.
- `detail`: `true` to return detailed project objects.

Project search matches project id, name/title, note, status, folder, and primary tag. Matching is case-insensitive.

Use `search-folders` when the user refers to a folder by name, parent, or note text. Use `search-tags` when the user refers to a tag by name, parent, or note text. Both are full-text search modes and emit `[omnifocus-warning] full-text-search ...` to stderr.

Use `tasks-by-tag-name` when the user asks for tasks with a specific tag or says tasks are "tagged", "marked", or "merket" with a tag by name. Use `tasks-by-tag` when the tag id is already known. Prefer these over `search-tasks query=<tag name>` because they go directly through the tag relationship instead of doing a broader text search.

Use the default `remaining` scope for tag task lookups unless the user explicitly asks for completed or all tagged tasks.

Task list modes default to `limit=10` and return `{mode,count,limit,tasks}`. Without `detail=true`, task list modes use one bulk OmniFocus `properties of every ...` read for the selected mode, then build JSON locally from those records. Use a larger `limit` or `limit=all` only when the user explicitly asks for a broader or complete dump. Use `detail=true` only when project, folder, tag, and note fields are needed, because that requires per-task detail reads and can be slow. `tasks-remaining`, `tasks-available`, `tasks-due`, `tasks-deferred`, and `tasks-flagged` filter by OmniFocus effective status, so tasks inside completed or dropped containers are excluded. Task modes also exclude OmniFocus project root tasks; use project modes for projects.

## Write Operations

Use `create-task` for new inbox tasks unless the user names a project. If `project=<project name or id>` is provided, the task is created at the end of that project.

Use `update` for task changes. Supported fields:

- `name` or `title`
- `note`
- `flagged`
- `completed`
- `due`
- `defer`
- `tag`
- `tags`: comma-separated list of tags to replace all existing task tags.
- `addTag`: one tag or comma-separated tags to add to a task.
- `removeTag`: one tag or comma-separated tags to remove from a task.
- `project`
- `estimatedMinutes` or `estimated`

Use `delete` only when the user's intent is explicit or after confirmation. Deletion returns the deleted task's summary JSON.

Use `create-project` for new top-level projects unless the user names a folder. If `folder=<folder name or id>` is provided, the project is created in that folder.

Use `update-project` for project changes. Supported fields:

- `name` or `title`
- `note`
- `flagged`
- `completed`
- `dropped`
- `status`: `active`, `on hold`, `done`, or `dropped`
- `due`
- `defer`
- `tag`
- `tags`: comma-separated list. Replaces all existing tags and fails if OmniFocus rejects the tag collection edit.
- `addTag`: one tag or comma-separated tags. Adds tags and fails if OmniFocus rejects the tag collection edit.
- `removeTag`: one tag or comma-separated tags.
- `folder`
- `sequential`
- `completedByChildren`
- `estimatedMinutes` or `estimated`

Use `delete-project` only when the user's intent is explicit or after confirmation. Deletion returns the deleted project's detailed JSON.

Use `create-folder`, `update-folder`, and `delete-folder` for folder management. Supported folder fields are:

- `name` or `title`
- `note`
- `folder` or `parent`: parent folder name/id, or empty/`none` to move to top level
- `hidden`

Use `create-tag`, `update-tag`, and `delete-tag` for tag management. Supported tag fields are:

- `name` or `title`
- `note`
- `tag` or `parent`: parent tag name/id, or empty/`none` to move to top level
- `allowsNextAction`
- `hidden`

Date values are parsed by macOS AppleScript in the current locale. If date parsing fails, ask the user for a clearer date/time.

## Response Style

Prefer concise updates such as:

- `Reading your OmniFocus inbox.`
- `Reading flagged tasks from OmniFocus.`
- `Reading OmniFocus projects.`
- `Reading OmniFocus folders.`
- `Reading OmniFocus tags.`
- `Searching OmniFocus projects.`
- `Searching OmniFocus folders.`
- `Searching OmniFocus tags.`
- `Updating the OmniFocus project.`
- `Updating the OmniFocus folder.`
- `Updating the OmniFocus tag.`
- `Reading the OmniFocus project details.`
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

Task search and tag task modes return JSON objects with `tasks`. Task list modes such as `tasks-remaining` return JSON like:

```json
{
  "mode": "tasks-remaining",
  "count": 12,
  "limit": 10,
  "tasks": [
    {
      "id": "omnifocus-task-id",
      "name": "Task name",
      "effectivelyCompleted": false,
      "effectivelyDropped": false
    }
  ]
}
```

Individual task objects look like:

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
