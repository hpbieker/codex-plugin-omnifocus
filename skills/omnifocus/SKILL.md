---
name: omnifocus
description: Search, read, create, update, and delete OmniFocus 4 tasks, projects, folders, and tags, including inbox, flagged, due, deferred, completed, available, remaining, project/folder/tag lists, search, and details.
---

# OmniFocus 4

Use this skill when the user asks to search OmniFocus 4, read tasks from OmniFocus 4, inspect OmniFocus projects, folders, or tags, summarize task lists, find due or flagged actions, extract task data from OmniFocus, create a task, project, folder, or tag, update a task, project, folder, or tag, delete a task, project, folder, or tag, or inspect detailed metadata for a specific task, project, folder, or tag.

## Requirements

- OmniFocus 4 must be installed on the Mac where Codex is running.
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
   - `create-task name=<title> [note=...] [project=...] [tagName=...|tagId=...] [due=...] [defer=...] [flagged=true] [estimatedMinutes=15]`: create a task.
   - `delete-task <task-id>`: delete a task.
   - `search-tasks query=<text> [scope=remaining] [limit=50|all]`: full-text search task summaries. Warning: emits `[omnifocus-warning] full-text-search ...`; prefer narrower commands when possible.
   - `task-detail <task-id>`: full task details.
   - `tasks-available [limit=50|all]`: incomplete available task summaries by effective status.
   - `tasks-by-tag <tag-id> [scope=remaining] [limit=50|all]`: list task summaries with a tag by id.
   - `tasks-by-tag-name <tag-name> [scope=remaining] [limit=50|all]`: list task summaries with a tag by exact name.
   - `tasks-completed [limit=50|all]`: completed task summaries by effective status.
   - `tasks-deferred [limit=50|all]`: incomplete task summaries with a defer date by effective status.
   - `tasks-due [limit=50|all]`: incomplete task summaries with a due date by effective status.
   - `tasks-flagged [limit=50|all]`: incomplete flagged task summaries by effective status.
   - `tasks-inbox [limit=50|all]`: incomplete inbox task summaries.
   - `tasks-remaining [limit=50|all]`: incomplete, not dropped task summaries by effective status, excluding project root tasks.
   - `update-task <task-id> name=... note=... flagged=true completed=false due=... defer=... tagName=... tagId=... project=... estimatedMinutes=15`: update a task.
   Project modes:
   - `create-project name=<title> [note=...] [folder=...] [tagName=...|tagId=...] [status=active] [due=...] [defer=...] [flagged=true] [sequential=true] [estimatedMinutes=15]`: create a project.
   - `delete-project <project-id>`: delete a project by id.
   - `project-detail <project-id>`: full project details by id.
   - `project-detail-by-name <project-name>`: full project details by exact name.
   - `projects [scope=remaining]`: projects. Supported scopes are `remaining`, `active`, `on-hold`, `completed`, `dropped`, and `all`.
   - `search-projects query=<text> [scope=remaining] [limit=50|all]`: full-text search project summaries. Warning: emits `[omnifocus-warning] full-text-search ...`; prefer narrower commands when possible.
   - `update-project <project-id> name=... note=... completed=true status=... due=... defer=... folder=... tagName=... tagId=... flagged=true sequential=true estimatedMinutes=15`: update a project by id.
   Folder modes:
   - `create-folder name=<title> [note=...] [folder=...]`: create a folder.
   - `delete-folder <folder-id>`: delete a folder by id.
   - `folder-detail <folder-id>`: full folder details by id.
   - `folder-detail-by-name <folder-name>`: full folder details by exact name.
   - `folders`: list folders.
   - `search-folders query=<text> [limit=50|all]`: full-text search folders. Warning: emits `[omnifocus-warning] full-text-search ...`; prefer narrower commands when possible.
   - `update-folder <folder-id> name=... note=... folder=... hidden=false`: update or move a folder by id.
   Tag modes:
   - `create-tag name=<title> [note=...] [parentTagName=...|parentTagId=...] [allowsNextAction=true]`: create a tag.
   - `delete-tag <tag-id>`: delete a tag by id.
   - `search-tags query=<text> [limit=50|all]`: full-text search tags. Warning: emits `[omnifocus-warning] full-text-search ...`; prefer narrower commands when possible.
   - `tag-detail <tag-id>`: full tag details by id.
   - `tag-detail-by-name <tag-name>`: full tag details by exact name.
   - `tags`: list tags.
   - `update-tag <tag-id> name=... note=... parentTagName=... parentTagId=... allowsNextAction=true hidden=false`: update or move a tag by id.
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
osascript ../../scripts/read_omnifocus_tasks.applescript search-projects query="Energy"
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

Use `search-tasks` when the user refers to a task by description, person, note text, id, or partial title. This is preferred over reading all `remaining` tasks and filtering locally.

Default to `scope=remaining` for general searches. Use `scope=all` or `scope=completed` only when the user explicitly asks for all tasks, completed tasks, history, or an old/closed item. This scope rule does not apply to direct lookup by task id with `task-detail`.

Full-text search modes emit `[omnifocus-warning] full-text-search ...` to stderr. Treat that warning as a signal to prefer a narrower mode such as `task-detail`, `tasks-by-tag`, or `tasks-by-tag-name` when the intent allows it.

Supported options:

- `query` or `q`: text to find.
- `scope`: `remaining`, `available`, `inbox`, `flagged`, `due`, `deferred`, `completed`, or `all`.
- `limit`: maximum returned task objects, or `all`.

Search matches task id, name/title, and note. Matching is case-insensitive. Use `tasks-by-tag-name` or `tasks-by-tag` for tag relationships.

Use `search-projects` when the user refers to a project by description, note text, status, id, or partial title. This is preferred over reading all projects and filtering locally.

Default to `scope=remaining` for project searches. Use `scope=all`, `scope=completed`, or `scope=dropped` only when the user explicitly asks for that wider set.

Supported project search options:

- `query` or `q`: text to find.
- `scope`: `remaining`, `active`, `on-hold`, `completed`, `dropped`, or `all`.
- `limit`: maximum returned project objects, or `all`.

Project search matches project id, name/title, note, and status. Matching is case-insensitive.

Use `search-folders` when the user refers to a folder by id, name, or note text. Use `search-tags` when the user refers to a tag by id, name, or note text. Both are full-text search modes and emit `[omnifocus-warning] full-text-search ...` to stderr. Both support `limit=all`.

Use `tasks-by-tag-name` when the user asks for tasks with a specific tag or says tasks are "tagged", "marked", or "merket" with a tag by name. Use `tasks-by-tag` when the tag id is already known. Prefer these over `search-tasks query=<tag name>` because they go directly through the tag relationship instead of doing a broader text search.

Use the default `remaining` scope for tag task lookups unless the user explicitly asks for completed or all tagged tasks. Tag task lookups support `limit=all`.

Task list modes default to `limit=50` and return `{mode,count,hasMore,limit,tasks}`. Tag task modes return `{tag,scope,count,hasMore,limit,tasks}`. Search modes return the same wrapper pattern with the matched collection name. Task list, tag task, and search modes do not compute an exact count by default; they fetch up to `limit + 1` matching items, return `count:null`, and set `hasMore:true` when there are more results. Use `limit=all` only when the user explicitly asks for a complete dump. Collection commands return summary fields; when full metadata is needed, first identify the item from the collection result, then call the matching detail command (`task-detail`, `project-detail`, `folder-detail`, or `tag-detail`) for that individual item. `tasks-remaining`, `tasks-available`, `tasks-due`, `tasks-deferred`, and `tasks-flagged` filter by OmniFocus effective status, so tasks inside completed or dropped containers are excluded. Task modes also exclude OmniFocus project root tasks; use project modes for projects.

## Write Operations

Use `create-task` for new inbox tasks unless the user names a project. If `project=<project name or id>` is provided, the task is created at the end of that project.

For tag fields, prefer explicit identity parameters. Use `tagId`, `tagIds`, `addTagIds`, `removeTagIds`, or `parentTagId` when the tag id came from a previous OmniFocus result. Use `tagName`, `tagNames`, `addTagNames`, `removeTagNames`, or `parentTagName` when the tag comes from user text. Do not pass a tag name in an id field or an id in a name field.

Use `update` for task changes. Supported fields:

- `name` or `title`
- `note`
- `flagged`
- `completed`
- `due`
- `defer`
- `tagId`: set the primary tag by id.
- `tagName`: set the primary tag by exact name.
- `tags` or `tagNames`: comma-separated list of tag names to replace all existing task tags.
- `tagIds`: comma-separated list of tag ids to replace all existing task tags.
- `addTag`, `addTagNames`: one tag name or comma-separated tag names to add to a task.
- `addTagIds`: one tag id or comma-separated tag ids to add to a task.
- `removeTag`, `removeTagNames`: one tag name or comma-separated tag names to remove from a task.
- `removeTagIds`: one tag id or comma-separated tag ids to remove from a task.
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
- `tagId`: set the primary tag by id.
- `tagName`: set the primary tag by exact name.
- `tags` or `tagNames`: comma-separated list of tag names. Replaces all existing tags.
- `tagIds`: comma-separated list of tag ids. Replaces all existing tags.
- `addTag`, `addTagNames`: one tag name or comma-separated tag names.
- `addTagIds`: one tag id or comma-separated tag ids.
- `removeTag`, `removeTagNames`: one tag name or comma-separated tag names.
- `removeTagIds`: one tag id or comma-separated tag ids.
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
- `parentTagId`: parent tag id, or empty to move to top level
- `parentTagName` or `parent`: parent tag exact name, or empty/`none` to move to top level
- `allowsNextAction`
- `hidden`

Date values are parsed by macOS AppleScript in the current locale. If date parsing fails, ask the user for a clearer date/time.

Create and update operations return `{ok:true,operation:<created|updated>,<object>:...}` with detailed JSON for the changed object. Delete operations return `{ok:true,operation:"deleted",<object>:...}` with the deleted object's JSON captured before deletion.

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

Collection commands return compact summaries. Use the matching detail command when full metadata is needed for one item.

Task list modes such as `tasks-remaining` return JSON like:

```json
{
  "mode": "tasks-remaining",
  "count": null,
  "hasMore": true,
  "limit": 50,
  "tasks": [
    {
      "id": "omnifocus-task-id",
      "name": "Task name",
      "flagged": false,
      "completed": false,
      "effectivelyCompleted": false,
      "effectivelyDropped": false,
      "due": "",
      "defer": ""
    }
  ]
}
```

Tag task modes return the tag and matching task summaries:

```json
{
  "tag": {
    "id": "omnifocus-tag-id",
    "name": "Tag name"
  },
  "scope": "remaining",
  "count": null,
  "hasMore": false,
  "limit": 50,
  "tasks": []
}
```

Project list modes return project summaries:

```json
[
  {
    "id": "omnifocus-project-id",
    "name": "Project name",
    "status": "active status",
    "completed": false,
    "due": "",
    "defer": "",
    "note": "Optional note"
  }
]
```

Folder list modes return folder summaries:

```json
[
  {
    "id": "omnifocus-folder-id",
    "name": "Folder name",
    "hidden": false,
    "note": "Optional note"
  }
]
```

Tag list modes return tag summaries:

```json
[
  {
    "id": "omnifocus-tag-id",
    "name": "Tag name",
    "allowsNextAction": true,
    "hidden": false,
    "availableTaskCount": 0,
    "remainingTaskCount": 0,
    "note": "Optional note"
  }
]
```

Task detail mode returns full metadata for one task:

```json
{
  "id": "omnifocus-task-id",
  "name": "Task name",
  "project": "Project name",
  "folder": "Folder name",
  "context": "Tag name",
  "flagged": false,
  "completed": false,
  "due": "",
  "defer": "",
  "estimatedMinutes": 15,
  "note": "Optional note",
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
  "count": null,
  "hasMore": false,
  "limit": 5,
  "tasks": [
    {
      "id": "omnifocus-task-id",
      "name": "Task name",
      "flagged": false,
      "completed": false,
      "effectivelyCompleted": false,
      "effectivelyDropped": false,
      "due": "",
      "defer": ""
    }
  ]
}
```

Project, folder, and tag search modes use the same wrapper pattern, with matched summaries under `projects`, `folders`, or `tags`.

## Notes

- If OmniFocus is closed, the script may launch it.
- If macOS blocks automation, tell the user to allow the host app to control OmniFocus.
- Prefer `remaining` when the user asks broadly for "oppgaver".
