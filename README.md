# OmniFocus Codex Plugin

This is a local Codex plugin that lets Codex read and manage tasks and projects from OmniFocus through AppleScript.

The plugin can search tasks, read task lists, inspect detailed task metadata, create tasks, update tasks, and delete tasks. Commands return JSON.

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
osascript scripts/read_omnifocus_tasks.applescript remaining
```

## Available Modes

- `inbox`: incomplete inbox tasks
- `available`: incomplete and unblocked tasks
- `remaining`: all incomplete tasks
- `flagged`: incomplete flagged tasks
- `due`: incomplete tasks with a due date
- `deferred`: incomplete tasks with a defer date
- `completed`: completed tasks
- `projects`: incomplete projects
- `search`: search tasks by text
- `detail <task-id>`: detailed metadata for one task
- `create`: create a new task
- `update <task-id>`: update an existing task
- `delete <task-id>`: delete an existing task

## Use From Codex

Once the plugin is installed, ask Codex naturally:

- `Read my tasks from OmniFocus`
- `Show flagged tasks in OmniFocus`
- `Summarize due OmniFocus tasks`
- `List my OmniFocus projects`
- `What is in my OmniFocus inbox?`
- `Create an OmniFocus task to call Anne tomorrow`
- `Mark this OmniFocus task as flagged`
- `Delete this OmniFocus task`

For broad task requests, the skill uses `remaining` by default.

For ambiguous updates or deletes, Codex should first identify the matching task and ask for confirmation.

## Direct Commands

Create an inbox task:

```sh
osascript scripts/read_omnifocus_tasks.applescript create name="Task title" note="Optional note"
```

Create a task in a project:

```sh
osascript scripts/read_omnifocus_tasks.applescript create name="Task title" project="Project name"
```

Read detailed task metadata:

```sh
osascript scripts/read_omnifocus_tasks.applescript detail task-id
```

Search tasks:

```sh
osascript scripts/read_omnifocus_tasks.applescript search query="Natalia" limit=5
```

Search completed or all tasks:

```sh
osascript scripts/read_omnifocus_tasks.applescript search query="Natalia" scope=completed
osascript scripts/read_omnifocus_tasks.applescript search query="Natalia" scope=all
```

Return detailed task objects from search:

```sh
osascript scripts/read_omnifocus_tasks.applescript search query="Natalia" detail=true
```

Update a task:

```sh
osascript scripts/read_omnifocus_tasks.applescript update task-id flagged=true note="Updated note"
```

Delete a task:

```sh
osascript scripts/read_omnifocus_tasks.applescript delete task-id
```

Supported create/update fields:

- `name` or `title`
- `note`
- `flagged`
- `completed`
- `due`
- `defer`
- `tag`
- `project`
- `estimatedMinutes` or `estimated`

Date values are parsed by macOS AppleScript using the current locale.

Search matches task id, name/title, note, project, folder, primary tag, and tags. Matching is case-insensitive.

Supported search options:

- `query` or `q`
- `scope`: `remaining`, `available`, `inbox`, `flagged`, `due`, `deferred`, `completed`, or `all`
- `limit`
- `detail`

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
