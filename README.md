# OmniFocus Codex Plugin

This is a local Codex plugin that lets Codex read and manage tasks, projects, folders, and tags from OmniFocus 4.

The plugin can search tasks, projects, folders, and tags; read lists; inspect detailed metadata; create, update, move, and delete objects; and manage task tags. Commands return JSON.

## Requirements

- macOS
- OmniFocus 4 installed and registered with bundle id `com.omnigroup.OmniFocus4`
- Codex with local plugin support
- Automation access from Codex or the terminal to OmniFocus

## File Structure

```text
.codex-plugin/plugin.json
assets/omnifocus-icon.png
skills/omnifocus/SKILL.md
scripts/benchmark_omnifocus.py
scripts/read_omnifocus_tasks.applescript
README.md
```

`plugin.json` registers the plugin and points Codex to the skill. The skill describes when and how Codex should use the AppleScript helper.

The plugin icon is the official OmniFocus 4 App Store artwork for app ID `1542143627`, published by The Omni Group.

## Install The Plugin

1. Place this folder somewhere Codex can read local plugins from.

2. Open or register the folder as a local Codex plugin.

   The plugin manifest is here:

   ```text
   .codex-plugin/plugin.json
   ```

3. Restart Codex if the plugin list does not update automatically.

4. Confirm that the plugin is visible as `omnifocus`.

## First Use

Run a direct test from the repository root:

```sh
osascript scripts/read_omnifocus_tasks.applescript projects
```

If macOS asks for permission, allow the terminal or Codex to control OmniFocus.

You can also check all remaining tasks:

```sh
osascript scripts/read_omnifocus_tasks.applescript tasks-remaining
```

## Performance Benchmark

Run the repeatable benchmark from the repository root:

```sh
python3 -B scripts/benchmark_omnifocus.py --output reports/omnifocus-benchmark.json
```

The benchmark creates temporary `CodexPerf-*` folders, tags, projects, and tasks, exercises the supported helper modes, deletes the temporary objects, and prints a JSON report. The report includes total time, median time, the slowest calls, task-list timings, and per-call results. OmniFocus Automation access is required.

## Available Modes

Task modes:

- `create-task`: create a new task
- `delete-task <task-id>`: delete an existing task
- `search-tasks query=<text> [limit=50|all]`: full-text search task summaries; warning: emits `[omnifocus-warning] full-text-search ...`
- `task-detail <task-id>`: detailed metadata for one task
- `tasks-available [limit=50|all]`: incomplete and unblocked tasks by effective status
- `tasks-by-tag <tag-id> [limit=50|all]`: list tasks with one tag by id
- `tasks-by-tag-name <tag-name> [limit=50|all]`: list tasks with one tag by exact name
- `tasks-completed [limit=50|all]`: completed tasks by effective status
- `tasks-deferred [limit=50|all]`: incomplete tasks with a defer date by effective status
- `tasks-due [limit=50|all]`: incomplete tasks with a due date by effective status
- `tasks-flagged [limit=50|all]`: incomplete flagged tasks by effective status
- `tasks-inbox [limit=50|all]`: incomplete inbox tasks
- `tasks-remaining [limit=50|all]`: incomplete, not dropped tasks by effective status, excluding project root tasks
- `update-task <task-id>`: update an existing task

Project modes:

- `create-project`: create a new project
- `delete-project <project-id>`: delete an existing project by id
- `project-detail <project-id>`: detailed metadata for one project by id
- `project-detail-by-name <project-name>`: detailed metadata for one project by exact name
- `projects [scope=remaining]`: projects; supported scopes are `remaining`, `active`, `on-hold`, `completed`, `dropped`, and `all`
- `search-projects query=<text> [limit=50|all]`: full-text search project summaries; warning: emits `[omnifocus-warning] full-text-search ...`
- `update-project <project-id>`: update an existing project by id

Folder modes:

- `create-folder`: create a new folder
- `delete-folder <folder-id>`: delete an existing folder by id
- `folder-detail <folder-id>`: detailed metadata for one folder by id
- `folder-detail-by-name <folder-name>`: detailed metadata for one folder by exact name
- `folders`: list folders
- `search-folders query=<text> [limit=50|all]`: full-text search folder summaries; warning: emits `[omnifocus-warning] full-text-search ...`
- `update-folder <folder-id>`: update or move an existing folder by id

Tag modes:

- `create-tag`: create a new tag
- `delete-tag <tag-id>`: delete an existing tag by id
- `search-tags query=<text> [limit=50|all]`: full-text search tag summaries; warning: emits `[omnifocus-warning] full-text-search ...`
- `tag-detail <tag-id>`: detailed metadata for one tag by id
- `tag-detail-by-name <tag-name>`: detailed metadata for one tag by exact name
- `tags`: list tags
- `update-tag <tag-id>`: update or move an existing tag by id

## Use From Codex

Once the plugin is installed, ask Codex naturally:

- `Read my tasks from OmniFocus`
- `Show flagged tasks in OmniFocus`
- `Summarize due OmniFocus tasks`
- `List my OmniFocus projects`
- `Search OmniFocus projects for energy`
- `Close this OmniFocus project`
- `Create an OmniFocus project for tax paperwork`
- `List my OmniFocus tags`
- `Create an OmniFocus tag for errands`
- `Move this project to the Work folder`
- `What is in my OmniFocus inbox?`
- `Create an OmniFocus task to call Anne tomorrow`
- `Mark this OmniFocus task as flagged`
- `Delete this OmniFocus task`

For broad task and project searches, the skill uses `remaining` by default. Use `all`, `completed`, or `dropped` only when the user explicitly asks for that wider set. Direct detail lookups by id do not need scope filtering.

Task list, search, and tag task modes accept numeric limits or `limit=all`. Task list and tag task modes default to `limit=50`, return `{count,hasMore,limit,tasks}`, and normally avoid computing an exact count; they fetch up to `limit + 1` matching tasks, return `count:null`, and set `hasMore:true` when there are more results. Use `count=true` only when an exact total is needed, because that requires reading the full matching set. Search modes return an exact `count` for matches. Use `limit=all` only for an explicit complete dump. Collection commands return summary fields only; use the matching detail command (`task-detail`, `project-detail`, `folder-detail`, or `tag-detail`) to fetch full metadata for individual items. Remaining-style list modes use OmniFocus effective status, so tasks inside completed or dropped containers are not returned as remaining. Task modes exclude OmniFocus project root tasks; use project modes for projects.

For ambiguous updates or deletes, Codex should first identify the matching task or project and ask for confirmation.

## Direct Commands

Create an inbox task:

```sh
osascript scripts/read_omnifocus_tasks.applescript create-task name="Task title" note="Optional note"
```

Create a task in a project:

```sh
osascript scripts/read_omnifocus_tasks.applescript create-task name="Task title" project="Project name"
```

Read detailed task metadata:

```sh
osascript scripts/read_omnifocus_tasks.applescript task-detail task-id
```

Search tasks:

```sh
osascript scripts/read_omnifocus_tasks.applescript search-tasks query="Natalia" limit=5
```

Search projects:

```sh
osascript scripts/read_omnifocus_tasks.applescript search-projects query="Energy"
```

Read detailed project metadata:

```sh
osascript scripts/read_omnifocus_tasks.applescript project-detail project-id
osascript scripts/read_omnifocus_tasks.applescript project-detail-by-name "Project name"
```

Create a project:

```sh
osascript scripts/read_omnifocus_tasks.applescript create-project name="Project title" note="Optional note"
```

Create a project in a folder:

```sh
osascript scripts/read_omnifocus_tasks.applescript create-project name="Project title" folder="Folder name"
```

Update a project:

```sh
osascript scripts/read_omnifocus_tasks.applescript update-project project-id completed=true
```

Delete a project:

```sh
osascript scripts/read_omnifocus_tasks.applescript delete-project project-id
```

List folders and tags:

```sh
osascript scripts/read_omnifocus_tasks.applescript folders
osascript scripts/read_omnifocus_tasks.applescript tags
```

Search folders or tags:

```sh
osascript scripts/read_omnifocus_tasks.applescript search-folders query="Work"
osascript scripts/read_omnifocus_tasks.applescript search-tags query="Office"
```

List tasks with a tag:

```sh
osascript scripts/read_omnifocus_tasks.applescript tasks-by-tag-name "Waiting"
```

Create, update, or delete a folder:

```sh
osascript scripts/read_omnifocus_tasks.applescript create-folder name="Folder title"
osascript scripts/read_omnifocus_tasks.applescript update-folder folder-id name="New folder title" parent="Parent folder"
osascript scripts/read_omnifocus_tasks.applescript delete-folder folder-id
```

Create, update, or delete a tag:

```sh
osascript scripts/read_omnifocus_tasks.applescript create-tag name="Tag title"
osascript scripts/read_omnifocus_tasks.applescript update-tag tag-id name="New tag title" parent="Parent tag"
osascript scripts/read_omnifocus_tasks.applescript delete-tag tag-id
```

Replace, add, or remove task tags:

```sh
osascript scripts/read_omnifocus_tasks.applescript update-task task-id tags="Office,Next"
osascript scripts/read_omnifocus_tasks.applescript update-task task-id addTag="Errand"
osascript scripts/read_omnifocus_tasks.applescript update-task task-id removeTag="Waiting"
```

Search completed or all tasks:

```sh
osascript scripts/read_omnifocus_tasks.applescript search-tasks query="Natalia" scope=completed
osascript scripts/read_omnifocus_tasks.applescript search-tasks query="Natalia" scope=all
```

Fetch details for one task from a search result:

```sh
osascript scripts/read_omnifocus_tasks.applescript task-detail task-id
```

Update a task:

```sh
osascript scripts/read_omnifocus_tasks.applescript update-task task-id flagged=true note="Updated note"
```

Delete a task:

```sh
osascript scripts/read_omnifocus_tasks.applescript delete-task task-id
```

Supported create/update fields:

- `name` or `title`
- `note`
- `flagged`
- `completed`
- `due`
- `defer`
- `tag`
- `tags`
- `addTag`
- `removeTag`
- `project`
- `estimatedMinutes` or `estimated`

Supported project create/update fields:

- `name` or `title`
- `note`
- `flagged`
- `completed`
- `dropped`
- `status`: `active`, `on hold`, `done`, or `dropped`
- `due`
- `defer`
- `tag`
- `tags`
- `addTag`
- `removeTag`
- `folder`
- `sequential`
- `completedByChildren`
- `estimatedMinutes` or `estimated`

Task tag fields:

- `tag`: set the primary tag.
- `tags`: replace all tags with a comma-separated list.
- `addTag`: add one tag or a comma-separated list.
- `removeTag`: remove one tag or a comma-separated list.

Project tag fields use the same names as task tag fields. Tag collection edits now fail directly if OmniFocus rejects them, instead of falling back to primary-tag assignment.

Supported folder create/update fields:

- `name` or `title`
- `note`
- `folder` or `parent`
- `hidden`

Supported tag create/update fields:

- `name` or `title`
- `note`
- `tag` or `parent`
- `allowsNextAction`
- `hidden`

Date values are parsed by macOS AppleScript using the current locale.

Search matches task id, name/title, and note. Matching is case-insensitive. General searches default to remaining tasks; use `scope=all` or `scope=completed` only when the user explicitly asks for all or completed tasks. Search and tag task modes accept `limit=all`. Use `tasks-by-tag-name` or `tasks-by-tag` instead of `search-tasks` when the intent is specifically to list tasks with a tag.

Full-text search modes write `[omnifocus-warning] full-text-search ...` to stderr so callers can spot broad searches and switch to narrower commands when possible.

Project search matches project id, name/title, note, and status. Matching is case-insensitive.

Project searches default to remaining projects; use `scope=all`, `scope=completed`, or `scope=dropped` only when explicitly requested.

Folder search matches folder id, name/title, and note. Tag search matches tag id, name/title, and note. Matching is case-insensitive.

Supported search options:

- `query` or `q`
- `scope`: `remaining`, `available`, `inbox`, `flagged`, `due`, `deferred`, `completed`, or `all`
- `limit`

Supported project search options:

- `query` or `q`
- `scope`: `remaining`, `active`, `on-hold`, `completed`, `dropped`, or `all`
- `limit`

Supported folder and tag search options:

- `query` or `q`
- `limit`

## Output Format

Collection commands return compact summaries. Use the matching detail command when you need project, folder, tag, notes, estimates, or other full metadata for one item.

Task list modes return a wrapper:

```json
{
  "mode": "tasks-remaining",
  "count": null,
  "hasMore": true,
  "limit": 50,
  "tasks": [
    {
      "id": "task-id",
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
    "id": "tag-id",
    "name": "Tag name"
  },
  "scope": "remaining",
  "count": null,
  "hasMore": false,
  "limit": 50,
  "tasks": []
}
```

Project lists return project summaries:

```json
[
  {
    "id": "project-id",
    "name": "Project name",
    "status": "active status",
    "completed": false,
    "due": "",
    "defer": "",
    "note": ""
  }
]
```

Folder lists return folder summaries:

```json
[
  {
    "id": "folder-id",
    "name": "Folder name",
    "hidden": false,
    "note": ""
  }
]
```

Tag lists return tag summaries:

```json
[
  {
    "id": "tag-id",
    "name": "Tag name",
    "allowsNextAction": true,
    "hidden": false,
    "availableTaskCount": 0,
    "remainingTaskCount": 0,
    "note": ""
  }
]
```

Detailed task reads return the task fields plus additional metadata:

```json
{
  "id": "task-id",
  "name": "Task name",
  "project": "Project name",
  "folder": "Folder name",
  "context": "Tag",
  "flagged": false,
  "completed": false,
  "due": "",
  "defer": "",
  "estimatedMinutes": 0,
  "note": "",
  "blocked": false,
  "next": false,
  "inInbox": true,
  "dropped": false,
  "effectivelyCompleted": false,
  "effectivelyDropped": false,
  "created": "",
  "modified": "",
  "completedDate": "",
  "effectiveDue": "",
  "effectiveDefer": "",
  "parent": "",
  "childCount": 0,
  "tags": []
}
```

Detailed project reads return the project fields plus additional metadata:

```json
{
  "id": "project-id",
  "name": "Project name",
  "folder": "Folder name",
  "status": "active status",
  "completed": false,
  "due": "",
  "defer": "",
  "note": "",
  "flagged": false,
  "blocked": false,
  "sequential": false,
  "completedByChildren": false,
  "dropped": false,
  "effectivelyCompleted": false,
  "effectivelyDropped": false,
  "created": "",
  "modified": "",
  "completedDate": "",
  "effectiveDue": "",
  "effectiveDefer": "",
  "estimatedMinutes": 0,
  "taskCount": 0,
  "availableTaskCount": 0,
  "completedTaskCount": 0,
  "tag": ""
}
```

Search returns a wrapper with an exact match count and matched summaries:

```json
{
  "query": "Natalia",
  "scope": "remaining",
  "count": 1,
  "limit": 5,
  "tasks": [
    {
      "id": "task-id",
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

Project search returns matched project summaries:

```json
{
  "query": "Energy",
  "scope": "all",
  "count": 1,
  "limit": 5,
  "projects": []
}
```

Folder and tag search return matched object summaries:

```json
{
  "query": "Office",
  "count": 1,
  "limit": 5,
  "tags": []
}
```

## Troubleshooting

If you get a macOS automation or access error, open:

```text
System Settings -> Privacy & Security -> Automation
```

Allow Codex, Terminal, or the app running `osascript` to control OmniFocus.

If the script cannot find OmniFocus, confirm that OmniFocus 4 is installed and Launch Services can resolve its bundle id:

```sh
osascript -e 'id of application "OmniFocus"'
```

The helper compiles and runs against the bundle id `com.omnigroup.OmniFocus4` in:

```text
scripts/read_omnifocus_tasks.applescript
```
