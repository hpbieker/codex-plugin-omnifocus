# OmniFocus Codex Plugin

This is a local Codex plugin that lets Codex read and manage tasks, projects, folders, and tags from OmniFocus through AppleScript.

The plugin can search tasks, projects, folders, and tags; read lists; inspect detailed metadata; create, update, move, and delete objects; and manage task tags. Commands return JSON.

## Requirements

- macOS
- OmniFocus 4 installed at `/Applications/OmniFocus.app`
- Codex with local plugin support
- Automation access from Codex or the terminal to OmniFocus

## File Structure

```text
.codex-plugin/plugin.json
assets/omnifocus-icon.png
skills/omnifocus/SKILL.md
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

## Available Modes

Task modes:

- `create-task`: create a new task
- `delete-task <task-id>`: delete an existing task
- `search-tasks`: full-text search tasks; warning: emits `[omnifocus-warning] full-text-search ...`
- `task-detail <task-id>`: detailed metadata for one task
- `tasks-available [limit=10|all]`: incomplete and unblocked tasks by effective status
- `tasks-by-tag <tag-id>`: list tasks with one tag by id
- `tasks-by-tag-name <tag-name>`: list tasks with one tag by exact name
- `tasks-completed [limit=10|all]`: completed tasks by effective status
- `tasks-deferred [limit=10|all]`: incomplete tasks with a defer date by effective status
- `tasks-due [limit=10|all]`: incomplete tasks with a due date by effective status
- `tasks-flagged [limit=10|all]`: incomplete flagged tasks by effective status
- `tasks-inbox [limit=10|all]`: incomplete inbox tasks
- `tasks-remaining [limit=10|all]`: incomplete, not dropped tasks by effective status, excluding project root tasks
- `update-task <task-id>`: update an existing task

Project modes:

- `create-project`: create a new project
- `delete-project <project-id>`: delete an existing project by id
- `project-detail <project-id>`: detailed metadata for one project by id
- `project-detail-by-name <project-name>`: detailed metadata for one project by exact name
- `projects [scope=remaining]`: projects; supported scopes are `remaining`, `active`, `on-hold`, `completed`, `dropped`, and `all`
- `search-projects`: full-text search projects; warning: emits `[omnifocus-warning] full-text-search ...`
- `update-project <project-id>`: update an existing project by id

Folder modes:

- `create-folder`: create a new folder
- `delete-folder <folder-id>`: delete an existing folder by id
- `folder-detail <folder-id>`: detailed metadata for one folder by id
- `folder-detail-by-name <folder-name>`: detailed metadata for one folder by exact name
- `folders`: list folders
- `search-folders`: full-text search folders; warning: emits `[omnifocus-warning] full-text-search ...`
- `update-folder <folder-id>`: update or move an existing folder by id

Tag modes:

- `create-tag`: create a new tag
- `delete-tag <tag-id>`: delete an existing tag by id
- `search-tags`: full-text search tags; warning: emits `[omnifocus-warning] full-text-search ...`
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

Task list modes default to `limit=10` and return `{mode,count,limit,tasks}`. Without `detail=true`, task list modes use one bulk OmniFocus `properties of every ...` read for the selected mode, then build JSON locally from those records. Use a larger `limit` or `limit=all` only for an explicit broader or complete dump. Use `detail=true` only when project, folder, tag, and note fields are needed, because that requires per-task detail reads and can be slow. Remaining-style list modes use OmniFocus effective status, so tasks inside completed or dropped containers are not returned as remaining. Task modes exclude OmniFocus project root tasks; use project modes for projects.

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
osascript scripts/read_omnifocus_tasks.applescript search-projects query="Energy" detail=true
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
osascript scripts/read_omnifocus_tasks.applescript search-folders query="Arbeid"
osascript scripts/read_omnifocus_tasks.applescript search-tags query="Kontoret"
```

List tasks with a tag:

```sh
osascript scripts/read_omnifocus_tasks.applescript tasks-by-tag-name "Venter på"
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

Return detailed task objects from search:

```sh
osascript scripts/read_omnifocus_tasks.applescript search-tasks query="Natalia" detail=true
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

Search matches task id, name/title, note, project, folder, primary tag, and tags. Matching is case-insensitive. General searches default to remaining tasks; use `scope=all` or `scope=completed` only when the user explicitly asks for all or completed tasks. Use `tasks-by-tag-name` or `tasks-by-tag` instead of `search-tasks` when the intent is specifically to list tasks with a tag.

Full-text search modes write `[omnifocus-warning] full-text-search ...` to stderr so callers can spot broad searches and switch to narrower commands when possible.

Project search matches project id, name/title, note, status, folder, and primary tag. Matching is case-insensitive.

Project searches default to remaining projects; use `scope=all`, `scope=completed`, or `scope=dropped` only when explicitly requested.

Folder search matches folder id, name/title, note, and parent. Tag search matches tag id, name/title, note, and parent. Matching is case-insensitive.

Supported search options:

- `query` or `q`
- `scope`: `remaining`, `available`, `inbox`, `flagged`, `due`, `deferred`, `completed`, or `all`
- `limit`
- `detail`

Supported project search options:

- `query` or `q`
- `scope`: `remaining`, `active`, `on-hold`, `completed`, `dropped`, or `all`
- `limit`
- `detail`

Supported folder and tag search options:

- `query` or `q`
- `limit`

## Data Format

Tasks are returned as JSON:

```json
[
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
    "note": ""
  }
]
```

Projects are returned as JSON:

```json
[
  {
    "id": "project-id",
    "name": "Project name",
    "folder": "Folder name",
    "status": "active status",
    "completed": false,
    "due": "",
    "defer": "",
    "note": ""
  }
]
```

Folders are returned as JSON:

```json
[
  {
    "id": "folder-id",
    "name": "Folder name",
    "parent": "Parent folder",
    "hidden": false,
    "note": ""
  }
]
```

Tags are returned as JSON:

```json
[
  {
    "id": "tag-id",
    "name": "Tag name",
    "parent": "Parent tag",
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

Search returns a wrapper with total count and matched tasks:

```json
{
  "query": "Natalia",
  "scope": "remaining",
  "count": 1,
  "limit": 5,
  "tasks": []
}
```

Project search returns a wrapper with total count and matched projects:

```json
{
  "query": "Energy",
  "scope": "all",
  "count": 1,
  "limit": 5,
  "projects": []
}
```

Folder and tag search return wrappers with total count and matched objects:

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

If the script cannot find OmniFocus, confirm that the app is installed here:

```text
/Applications/OmniFocus.app
```

If OmniFocus is installed somewhere else, update `tell application "/Applications/OmniFocus.app"` in:

```text
scripts/read_omnifocus_tasks.applescript
```
