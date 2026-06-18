property omniFocusAppID : "com.omnigroup.OmniFocus4"

using terms from application id "com.omnigroup.OmniFocus4"

on run argv
	set requestedMode to "tasks-remaining"
	if (count of argv) > 0 then set requestedMode to item 1 of argv
	
	set validModes to {"tasks-inbox", "tasks-available", "tasks-remaining", "tasks-flagged", "tasks-due", "tasks-deferred", "tasks-completed", "projects", "search-projects", "project-detail", "project-detail-by-name", "create-project", "update-project", "delete-project", "folders", "search-folders", "folder-detail", "folder-detail-by-name", "create-folder", "update-folder", "delete-folder", "tags", "search-tags", "tag-detail", "tag-detail-by-name", "tasks-by-tag", "tasks-by-tag-name", "create-tag", "update-tag", "delete-tag", "search-tasks", "task-detail", "create-task", "update-task", "delete-task"}
	if validModes does not contain requestedMode then
		error "Unknown mode '" & requestedMode & "'. Use one of: tasks-inbox, tasks-available, tasks-remaining, tasks-flagged, tasks-due, tasks-deferred, tasks-completed, projects, search-projects, project-detail, project-detail-by-name, create-project, update-project, delete-project, folders, search-folders, folder-detail, folder-detail-by-name, create-folder, update-folder, delete-folder, tags, search-tags, tag-detail, tag-detail-by-name, tasks-by-tag, tasks-by-tag-name, create-tag, update-tag, delete-tag, search-tasks, task-detail, create-task, update-task, delete-task."
	end if
	
	tell application id (omniFocusAppID as text)
		tell front document
			if requestedMode is "projects" then
				set optionsMap to my parseOptions(argv, 2)
				set projectProperties to properties of every «class FCfx»
				return my projectsToJSON(projectProperties, optionsMap)
			else if requestedMode is "folders" then
				set folderProperties to properties of every «class FCff»
				return my foldersToJSON(folderProperties)
			else if requestedMode is "search-folders" then
				set optionsMap to my parseOptions(argv, 2)
				return my searchFoldersToJSON(optionsMap)
			else if requestedMode is "folder-detail" then
				if (count of argv) < 2 then error "folder-detail requires a folder id."
				set folderItem to my findFolderByID(item 2 of argv)
				return my detailFolderToJSON(folderItem)
			else if requestedMode is "folder-detail-by-name" then
				if (count of argv) < 2 then error "folder-detail-by-name requires a folder name."
				set folderItem to my findFolderByName(item 2 of argv)
				return my detailFolderToJSON(folderItem)
			else if requestedMode is "create-folder" then
				set optionsMap to my parseOptions(argv, 2)
				set folderItem to my createFolder(optionsMap)
				return my folderOperationToJSON("created", folderItem)
			else if requestedMode is "update-folder" then
				if (count of argv) < 2 then error "update-folder requires a folder id."
				set folderItem to my findFolderByID(item 2 of argv)
				set optionsMap to my parseOptions(argv, 3)
				my updateFolder(folderItem, optionsMap)
				return my folderOperationToJSON("updated", folderItem)
			else if requestedMode is "delete-folder" then
				if (count of argv) < 2 then error "delete-folder requires a folder id."
				set folderItem to my findFolderByID(item 2 of argv)
				set deletedFolderJSON to my detailFolderToJSON(folderItem)
				delete folderItem
				return "{\"ok\":true,\"operation\":\"deleted\",\"folder\":" & deletedFolderJSON & "}"
			else if requestedMode is "tags" then
				set tagProperties to properties of every «class FCfc»
				return my tagsToJSON(tagProperties)
			else if requestedMode is "search-tags" then
				set optionsMap to my parseOptions(argv, 2)
				return my searchTagsToJSON(optionsMap)
			else if requestedMode is "tag-detail" then
				if (count of argv) < 2 then error "tag-detail requires a tag id."
				set tagItem to my findTagByID(item 2 of argv)
				return my detailTagToJSON(tagItem)
			else if requestedMode is "tag-detail-by-name" then
				if (count of argv) < 2 then error "tag-detail-by-name requires a tag name."
				set tagItem to my findTagByName(item 2 of argv)
				return my detailTagToJSON(tagItem)
			else if requestedMode is "tasks-by-tag" then
				if (count of argv) < 2 then error "tasks-by-tag requires a tag id."
				set tagItem to my findTagByID(item 2 of argv)
				set optionsMap to my parseOptions(argv, 3)
				return my tagTasksToJSON(tagItem, optionsMap)
			else if requestedMode is "tasks-by-tag-name" then
				if (count of argv) < 2 then error "tasks-by-tag-name requires a tag name."
				set tagItem to my findTagByName(item 2 of argv)
				set optionsMap to my parseOptions(argv, 3)
				return my tagTasksToJSON(tagItem, optionsMap)
			else if requestedMode is "create-tag" then
				set optionsMap to my parseOptions(argv, 2)
				set tagItem to my createTag(optionsMap)
				return my tagOperationToJSON("created", tagItem)
			else if requestedMode is "update-tag" then
				if (count of argv) < 2 then error "update-tag requires a tag id."
				set tagItem to my findTagByID(item 2 of argv)
				set optionsMap to my parseOptions(argv, 3)
				my updateTag(tagItem, optionsMap)
				return my tagOperationToJSON("updated", tagItem)
			else if requestedMode is "delete-tag" then
				if (count of argv) < 2 then error "delete-tag requires a tag id."
				set tagItem to my findTagByID(item 2 of argv)
				set deletedTagJSON to my detailTagToJSON(tagItem)
				delete tagItem
				return "{\"ok\":true,\"operation\":\"deleted\",\"tag\":" & deletedTagJSON & "}"
			else if requestedMode is "search-projects" then
				set optionsMap to my parseOptions(argv, 2)
				return my searchProjectsToJSON(optionsMap)
			else if requestedMode is "project-detail" then
				if (count of argv) < 2 then error "project-detail requires a project id."
				set projectItem to my findProjectByID(item 2 of argv)
				return my detailProjectToJSON(projectItem)
			else if requestedMode is "project-detail-by-name" then
				if (count of argv) < 2 then error "project-detail-by-name requires a project name."
				set projectItem to my findProjectByName(item 2 of argv)
				return my detailProjectToJSON(projectItem)
			else if requestedMode is "create-project" then
				set optionsMap to my parseOptions(argv, 2)
				set projectItem to my createProject(optionsMap)
				return my projectOperationToJSON("created", projectItem)
			else if requestedMode is "update-project" then
				if (count of argv) < 2 then error "update-project requires a project id."
				set projectItem to my findProjectByID(item 2 of argv)
				set optionsMap to my parseOptions(argv, 3)
				my updateProject(projectItem, optionsMap)
				return my projectOperationToJSON("updated", projectItem)
			else if requestedMode is "delete-project" then
				if (count of argv) < 2 then error "delete-project requires a project id."
				set projectItem to my findProjectByID(item 2 of argv)
				set deletedProjectJSON to my detailProjectToJSON(projectItem)
				delete projectItem
				return "{\"ok\":true,\"operation\":\"deleted\",\"project\":" & deletedProjectJSON & "}"
			else if requestedMode is "search-tasks" then
				set optionsMap to my parseOptions(argv, 2)
				return my searchTasksToJSON(optionsMap)
			else if requestedMode is "task-detail" then
				if (count of argv) < 2 then error "task-detail requires a task id."
				set taskItem to my findTaskByID(item 2 of argv)
				return my detailTaskToJSON(taskItem)
			else if requestedMode is "create-task" then
				set optionsMap to my parseOptions(argv, 2)
				set taskItem to my createTask(optionsMap)
				return my operationToJSON("created", taskItem)
			else if requestedMode is "update-task" then
				if (count of argv) < 2 then error "update-task requires a task id."
				set taskItem to my findTaskByID(item 2 of argv)
				set optionsMap to my parseOptions(argv, 3)
				my updateTask(taskItem, optionsMap)
				return my operationToJSON("updated", taskItem)
			else if requestedMode is "delete-task" then
				if (count of argv) < 2 then error "delete-task requires a task id."
				set taskItem to my findTaskByID(item 2 of argv)
				set deletedTaskJSON to my taskToJSON(taskItem)
				delete taskItem
				return "{\"ok\":true,\"operation\":\"deleted\",\"task\":" & deletedTaskJSON & "}"
			else
				set optionsMap to my parseOptions(argv, 2)
				return my bulkTaskListToJSON(requestedMode, optionsMap)
			end if
		end tell
	end tell
end run

on createTask(optionsMap)
	set taskName to my optionValue(optionsMap, "name")
	if taskName is "" then set taskName to my optionValue(optionsMap, "title")
	if taskName is "" then error "create requires name=<task title>."
	
	tell application id (omniFocusAppID as text)
		tell front document
			set projectName to my optionValue(optionsMap, "project")
			if projectName is not "" then
				set targetProject to my findProjectByName(projectName)
				set taskItem to make new «class FCac» at end of tasks of targetProject with properties {name:taskName}
			else
				set taskItem to make new «class FCit» with properties {name:taskName}
			end if
		end tell
	end tell
	
	my updateTask(taskItem, optionsMap)
	return taskItem
end createTask

on createProject(optionsMap)
	set projectName to my optionValue(optionsMap, "name")
	if projectName is "" then set projectName to my optionValue(optionsMap, "title")
	if projectName is "" then error "create-project requires name=<project title>."
	
	tell application id (omniFocusAppID as text)
		tell front document
			set folderName to my optionValue(optionsMap, "folder")
			set projectItem to make new project at end of projects with properties {name:projectName}
		end tell
	end tell
	
	my updateProject(projectItem, optionsMap)
	return projectItem
end createProject

on createFolder(optionsMap)
	set folderName to my optionValue(optionsMap, "name")
	if folderName is "" then set folderName to my optionValue(optionsMap, "title")
	if folderName is "" then error "create-folder requires name=<folder title>."
	
	tell application id (omniFocusAppID as text)
		tell front document
			set parentFolderName to my optionValue(optionsMap, "folder")
			if parentFolderName is "" then set parentFolderName to my optionValue(optionsMap, "parent")
			if parentFolderName is not "" then
				set parentFolder to my findFolderByName(parentFolderName)
				set folderItem to make new folder at end of folders of parentFolder with properties {name:folderName}
			else
				set folderItem to make new folder at end of folders with properties {name:folderName}
			end if
		end tell
	end tell
	
	my updateFolder(folderItem, optionsMap)
	return folderItem
end createFolder

on createTag(optionsMap)
	set tagName to my optionValue(optionsMap, "name")
	if tagName is "" then set tagName to my optionValue(optionsMap, "title")
	if tagName is "" then error "create-tag requires name=<tag title>."
	
	tell application id (omniFocusAppID as text)
		tell front document
			set parentTagName to my optionValue(optionsMap, "tag")
			if parentTagName is "" then set parentTagName to my optionValue(optionsMap, "parent")
			if parentTagName is not "" then
				set parentTag to my findTagByName(parentTagName)
				set tagItem to make new tag at end of tags of parentTag with properties {name:tagName}
			else
				set tagItem to make new tag at end of tags with properties {name:tagName}
			end if
		end tell
	end tell
	
	my updateTag(tagItem, optionsMap)
	return tagItem
end createTag

on updateTask(taskItem, optionsMap)
	tell application id (omniFocusAppID as text)
		set newName to my optionValue(optionsMap, "name")
		if newName is "" then set newName to my optionValue(optionsMap, "title")
		if newName is not "" then set name of taskItem to newName
		
		if my hasOption(optionsMap, "note") then set note of taskItem to my optionValue(optionsMap, "note")
		if my hasOption(optionsMap, "flagged") then set flagged of taskItem to my boolValue(my optionValue(optionsMap, "flagged"))
		if my hasOption(optionsMap, "estimatedMinutes") then set «property FCEM» of taskItem to my intValue(my optionValue(optionsMap, "estimatedMinutes"))
		if my hasOption(optionsMap, "estimated") then set «property FCEM» of taskItem to my intValue(my optionValue(optionsMap, "estimated"))
		if my hasOption(optionsMap, "due") then set «property FCDd» of taskItem to my optionalDateValue(my optionValue(optionsMap, "due"))
		if my hasOption(optionsMap, "defer") then set «property FCDs» of taskItem to my optionalDateValue(my optionValue(optionsMap, "defer"))
		
		if my hasOption(optionsMap, "tag") then
			set tagName to my optionValue(optionsMap, "tag")
			if tagName is "" then
				set «property FCpt» of taskItem to missing value
			else
				set «property FCpt» of taskItem to my findTagByName(tagName)
			end if
		end if
		if my hasOption(optionsMap, "tags") then my setTagsOnItem(taskItem, my optionValue(optionsMap, "tags"))
		if my hasOption(optionsMap, "addTag") then my addTagsToItem(taskItem, my optionValue(optionsMap, "addTag"))
		if my hasOption(optionsMap, "removeTag") then my removeTagsFromItem(taskItem, my optionValue(optionsMap, "removeTag"))
		
		if my hasOption(optionsMap, "project") then
			set projectName to my optionValue(optionsMap, "project")
			if projectName is not "" then
				set targetProject to my findProjectByName(projectName)
				move taskItem to end of tasks of targetProject
			end if
		end if
		
		if my hasOption(optionsMap, "completed") then
			if my boolValue(my optionValue(optionsMap, "completed")) then
				mark complete taskItem
			else
				mark incomplete taskItem
			end if
		end if
	end tell
end updateTask

on updateProject(projectItem, optionsMap)
	tell application id (omniFocusAppID as text)
		set newName to my optionValue(optionsMap, "name")
		if newName is "" then set newName to my optionValue(optionsMap, "title")
		if newName is not "" then set name of projectItem to newName
		
		if my hasOption(optionsMap, "note") then set note of projectItem to my optionValue(optionsMap, "note")
		if my hasOption(optionsMap, "flagged") then set flagged of projectItem to my boolValue(my optionValue(optionsMap, "flagged"))
		if my hasOption(optionsMap, "sequential") then set sequential of projectItem to my boolValue(my optionValue(optionsMap, "sequential"))
		if my hasOption(optionsMap, "completedByChildren") then set «property FCbc» of projectItem to my boolValue(my optionValue(optionsMap, "completedByChildren"))
		if my hasOption(optionsMap, "estimatedMinutes") then set «property FCEM» of projectItem to my intValue(my optionValue(optionsMap, "estimatedMinutes"))
		if my hasOption(optionsMap, "estimated") then set «property FCEM» of projectItem to my intValue(my optionValue(optionsMap, "estimated"))
		if my hasOption(optionsMap, "due") then set «property FCDd» of projectItem to my optionalDateValue(my optionValue(optionsMap, "due"))
		if my hasOption(optionsMap, "defer") then set «property FCDs» of projectItem to my optionalDateValue(my optionValue(optionsMap, "defer"))
		
		if my hasOption(optionsMap, "folder") then
			my moveProjectToFolder(projectItem, my optionValue(optionsMap, "folder"))
		end if
		
		if my hasOption(optionsMap, "tag") then
			set tagName to my optionValue(optionsMap, "tag")
			if tagName is "" then
				set «property FCpt» of projectItem to missing value
			else
				set «property FCpt» of projectItem to my findTagByName(tagName)
			end if
		end if
		if my hasOption(optionsMap, "tags") then my setTagsOnItem(projectItem, my optionValue(optionsMap, "tags"))
		if my hasOption(optionsMap, "addTag") then my addTagsToItem(projectItem, my optionValue(optionsMap, "addTag"))
		if my hasOption(optionsMap, "removeTag") then my removeTagsFromItem(projectItem, my optionValue(optionsMap, "removeTag"))
		
		if my hasOption(optionsMap, "status") then my setProjectStatus(projectItem, my optionValue(optionsMap, "status"))
		
		if my hasOption(optionsMap, "completed") then
			if my boolValue(my optionValue(optionsMap, "completed")) then
				mark complete projectItem
			else
				mark incomplete projectItem
			end if
		end if
		
		if my hasOption(optionsMap, "dropped") then
			if my boolValue(my optionValue(optionsMap, "dropped")) then
				mark dropped projectItem
			else
				mark incomplete projectItem
			end if
		end if
	end tell
end updateProject

on updateFolder(folderItem, optionsMap)
	tell application id (omniFocusAppID as text)
		set newName to my optionValue(optionsMap, "name")
		if newName is "" then set newName to my optionValue(optionsMap, "title")
		if newName is not "" then set name of folderItem to newName
		if my hasOption(optionsMap, "note") then set note of folderItem to my optionValue(optionsMap, "note")
		if my hasOption(optionsMap, "hidden") then set hidden of folderItem to my boolValue(my optionValue(optionsMap, "hidden"))
		if my hasOption(optionsMap, "folder") then my moveFolderToFolder(folderItem, my optionValue(optionsMap, "folder"))
		if my hasOption(optionsMap, "parent") then my moveFolderToFolder(folderItem, my optionValue(optionsMap, "parent"))
	end tell
end updateFolder

on updateTag(tagItem, optionsMap)
	tell application id (omniFocusAppID as text)
		set newName to my optionValue(optionsMap, "name")
		if newName is "" then set newName to my optionValue(optionsMap, "title")
		if newName is not "" then set name of tagItem to newName
		if my hasOption(optionsMap, "note") then set note of tagItem to my optionValue(optionsMap, "note")
		if my hasOption(optionsMap, "allowsNextAction") then set «property FCNA» of tagItem to my boolValue(my optionValue(optionsMap, "allowsNextAction"))
		if my hasOption(optionsMap, "hidden") then set hidden of tagItem to my boolValue(my optionValue(optionsMap, "hidden"))
		if my hasOption(optionsMap, "tag") then my moveTagToTag(tagItem, my optionValue(optionsMap, "tag"))
		if my hasOption(optionsMap, "parent") then my moveTagToTag(tagItem, my optionValue(optionsMap, "parent"))
	end tell
end updateTag

on moveProjectToFolder(projectItem, folderName)
	tell application id (omniFocusAppID as text)
		if folderName is "" or folderName is "none" or folderName is "null" then
			move projectItem to end of sections
		else
			set targetFolder to my findFolderByName(folderName)
			move projectItem to end of sections of targetFolder
		end if
	end tell
end moveProjectToFolder

on moveFolderToFolder(folderItem, folderName)
	tell application id (omniFocusAppID as text)
		if folderName is "" or folderName is "none" or folderName is "null" then
			move folderItem to end of sections
		else
			set targetFolder to my findFolderByName(folderName)
			move folderItem to end of sections of targetFolder
		end if
	end tell
end moveFolderToFolder

on moveTagToTag(tagItem, parentTagName)
	tell application id (omniFocusAppID as text)
		if parentTagName is "" or parentTagName is "none" or parentTagName is "null" then
			move tagItem to end of tags
		else
			set parentTag to my findTagByName(parentTagName)
			move tagItem to end of tags of parentTag
		end if
	end tell
end moveTagToTag

on setTagsOnItem(targetItem, tagListText)
	tell application id (omniFocusAppID as text)
		set existingTags to tags of targetItem
		repeat with tagItem in existingTags
			remove tagItem from targetItem
		end repeat
		set «property FCpt» of targetItem to missing value
	end tell
	my addTagsToItem(targetItem, tagListText)
end setTagsOnItem

on addTagsToItem(targetItem, tagListText)
	set tagNames to my splitList(tagListText)
	tell application id (omniFocusAppID as text)
		repeat with tagName in tagNames
			if (tagName as text) is not "" then
				set tagItem to my findTagByName(tagName as text)
				add tagItem to tags of targetItem
			end if
		end repeat
	end tell
end addTagsToItem

on removeTagsFromItem(targetItem, tagListText)
	set tagNames to my splitList(tagListText)
	tell application id (omniFocusAppID as text)
		repeat with tagName in tagNames
			if (tagName as text) is not "" then
				set tagItem to my findTagByName(tagName as text)
				remove tagItem from tags of targetItem
			end if
		end repeat
	end tell
end removeTagsFromItem

on setProjectStatus(projectItem, statusText)
	tell application id (omniFocusAppID as text)
		if statusText is "active" or statusText is "active status" then
			set status of projectItem to active status
		else if statusText is "on hold" or statusText is "on hold status" then
			set status of projectItem to on hold status
		else if statusText is "done" or statusText is "done status" or statusText is "completed" then
			set status of projectItem to done status
		else if statusText is "dropped" or statusText is "dropped status" then
			set status of projectItem to dropped status
		else
			error "Unknown project status '" & statusText & "'. Use active, on hold, done, or dropped."
		end if
	end tell
end setProjectStatus

on findTaskByID(taskID)
	tell application id (omniFocusAppID as text)
		tell front document
			return task id taskID
		end tell
	end tell
end findTaskByID

on findProjectByID(projectID)
	tell application id (omniFocusAppID as text)
		tell front document
			return project id projectID
		end tell
	end tell
end findProjectByID

on findProjectByName(projectName)
	tell application id (omniFocusAppID as text)
		tell front document
			return first flattened project where name is projectName
		end tell
	end tell
end findProjectByName

on findFolderByID(folderID)
	tell application id (omniFocusAppID as text)
		tell front document
			return folder id folderID
		end tell
	end tell
end findFolderByID

on findFolderByName(folderName)
	tell application id (omniFocusAppID as text)
		tell front document
			return first flattened folder where name is folderName
		end tell
	end tell
end findFolderByName

on findTagByID(tagID)
	tell application id (omniFocusAppID as text)
		tell front document
			return tag id tagID
		end tell
	end tell
end findTagByID

on findTagByName(tagName)
	tell application id (omniFocusAppID as text)
		tell front document
			return first flattened tag where name is tagName
		end tell
	end tell
end findTagByName

on searchTasksToJSON(optionsMap)
	set searchQuery to my optionValue(optionsMap, "query")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "q")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "name")
	if searchQuery is "" then error "search requires query=<text>."
	
	set searchScope to my optionValue(optionsMap, "scope")
	if searchScope is "" then set searchScope to "remaining"
	my warnFullTextSearch("search-tasks", searchQuery, searchScope)
	
	set resultLimit to my listLimitValue(optionsMap, 50)
	
	set taskProperties to my taskPropertiesForSearch(searchScope, searchQuery)
	
	set jsonItems to {}
	set matchedCount to count of taskProperties
	set emitCount to matchedCount
	if resultLimit is not -1 and emitCount > resultLimit then set emitCount to resultLimit
	repeat with taskIndex from 1 to emitCount
		set taskPropertiesItem to item taskIndex of taskProperties
		set end of jsonItems to my taskPropertiesToJSON(taskPropertiesItem)
	end repeat
	
	return "{\"query\":\"" & my escapeJSON(searchQuery) & "\",\"scope\":\"" & my escapeJSON(searchScope) & "\",\"count\":" & matchedCount & ",\"limit\":" & my limitJSONValue(resultLimit) & ",\"tasks\":[" & my joinText(jsonItems, ",") & "]}"
end searchTasksToJSON

on taskPropertiesForSearch(searchScope, searchQuery)
	tell application id (omniFocusAppID as text)
		tell front document
			if searchScope is "all" then return properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and (name contains searchQuery or note contains searchQuery or id contains searchQuery)
			if searchScope is "inbox" then return properties of every «class FCit» where name contains searchQuery or note contains searchQuery or id contains searchQuery
			if searchScope is "completed" then return properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is true and (name contains searchQuery or note contains searchQuery or id contains searchQuery)
			if searchScope is "remaining" then return properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and (name contains searchQuery or note contains searchQuery or id contains searchQuery)
			if searchScope is "available" then return properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and blocked is false and (name contains searchQuery or note contains searchQuery or id contains searchQuery)
			if searchScope is "flagged" then return properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and flagged is true and (name contains searchQuery or note contains searchQuery or id contains searchQuery)
			if searchScope is "due" then return properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and «property FCDd» is not missing value and (name contains searchQuery or note contains searchQuery or id contains searchQuery)
			if searchScope is "deferred" then return properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and «property FCDs» is not missing value and (name contains searchQuery or note contains searchQuery or id contains searchQuery)
		end tell
	end tell
	error "Unknown task search scope '" & searchScope & "'. Use remaining, available, inbox, flagged, due, deferred, completed, or all."
end taskPropertiesForSearch

on searchProjectsToJSON(optionsMap)
	set searchQuery to my optionValue(optionsMap, "query")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "q")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "name")
	if searchQuery is "" then error "search-projects requires query=<text>."
	
	set searchScope to my optionValue(optionsMap, "scope")
	if searchScope is "" then set searchScope to "remaining"
	my warnFullTextSearch("search-projects", searchQuery, searchScope)
	
	set resultLimit to my listLimitValue(optionsMap, 50)
	
	set projectPropertiesItems to my projectPropertiesForSearchScope(searchScope)
	
	set jsonItems to {}
	set matchedCount to 0
	repeat with projectPropertiesItem in projectPropertiesItems
		if my projectPropertiesMatchesQuery(projectPropertiesItem, searchQuery) then
			set matchedCount to matchedCount + 1
			if resultLimit is -1 or matchedCount ≤ resultLimit then
				set end of jsonItems to my projectPropertiesToJSON(projectPropertiesItem)
			end if
		end if
	end repeat
	
	return "{\"query\":\"" & my escapeJSON(searchQuery) & "\",\"scope\":\"" & my escapeJSON(searchScope) & "\",\"count\":" & matchedCount & ",\"limit\":" & my limitJSONValue(resultLimit) & ",\"projects\":[" & my joinText(jsonItems, ",") & "]}"
end searchProjectsToJSON

on projectPropertiesForSearchScope(searchScope)
	tell application id (omniFocusAppID as text)
		tell front document
			if searchScope is "all" then return properties of every «class FCfx»
			if searchScope is "completed" or searchScope is "done" then return properties of every «class FCfx» where completed is true
			if searchScope is "dropped" then return properties of every «class FCfx» where «property FC-d» is true
			if searchScope is "on-hold" or searchScope is "on hold" then return properties of every «class FCfx» where status is on hold status
			if searchScope is "active" then return properties of every «class FCfx» where status is active status
			if searchScope is "remaining" then return properties of every «class FCfx» where completed is false
		end tell
	end tell
	error "Unknown project search scope '" & searchScope & "'. Use remaining, active, on-hold, completed, dropped, or all."
end projectPropertiesForSearchScope

on searchFoldersToJSON(optionsMap)
	set searchQuery to my optionValue(optionsMap, "query")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "q")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "name")
	if searchQuery is "" then error "search-folders requires query=<text>."
	
	set resultLimit to my listLimitValue(optionsMap, 50)
	my warnFullTextSearch("search-folders", searchQuery, "")
	
	tell application id (omniFocusAppID as text)
		tell front document
			set folderPropertiesItems to properties of every «class FCff»
		end tell
	end tell
	
	set jsonItems to {}
	set matchedCount to 0
	repeat with folderPropertiesItem in folderPropertiesItems
		if my folderPropertiesMatchesQuery(folderPropertiesItem, searchQuery) then
			set matchedCount to matchedCount + 1
			if resultLimit is -1 or matchedCount ≤ resultLimit then set end of jsonItems to my folderPropertiesToJSON(folderPropertiesItem)
		end if
	end repeat
	
	return "{\"query\":\"" & my escapeJSON(searchQuery) & "\",\"count\":" & matchedCount & ",\"limit\":" & my limitJSONValue(resultLimit) & ",\"folders\":[" & my joinText(jsonItems, ",") & "]}"
end searchFoldersToJSON

on searchTagsToJSON(optionsMap)
	set searchQuery to my optionValue(optionsMap, "query")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "q")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "name")
	if searchQuery is "" then error "search-tags requires query=<text>."
	
	set resultLimit to my listLimitValue(optionsMap, 50)
	my warnFullTextSearch("search-tags", searchQuery, "")
	
	tell application id (omniFocusAppID as text)
		tell front document
			set tagPropertiesItems to properties of every «class FCfc»
		end tell
	end tell
	
	set jsonItems to {}
	set matchedCount to 0
	repeat with tagPropertiesItem in tagPropertiesItems
		if my tagPropertiesMatchesQuery(tagPropertiesItem, searchQuery) then
			set matchedCount to matchedCount + 1
			if resultLimit is -1 or matchedCount ≤ resultLimit then set end of jsonItems to my tagPropertiesToJSON(tagPropertiesItem)
		end if
	end repeat
	
	return "{\"query\":\"" & my escapeJSON(searchQuery) & "\",\"count\":" & matchedCount & ",\"limit\":" & my limitJSONValue(resultLimit) & ",\"tags\":[" & my joinText(jsonItems, ",") & "]}"
end searchTagsToJSON

on tagTasksToJSON(tagItem, optionsMap)
	set searchScope to my optionValue(optionsMap, "scope")
	if searchScope is "" then set searchScope to "remaining"
	
	set resultLimit to my listLimitValue(optionsMap, 50)
	set includeExactCount to false
	if my hasOption(optionsMap, "count") then set includeExactCount to my boolValue(my optionValue(optionsMap, "count"))
	
	set tagId to id of tagItem
	set tagName to name of tagItem
	
	if includeExactCount or resultLimit is -1 then
		set taskProperties to my exactTagTaskProperties(tagItem, searchScope)
	else
		set taskProperties to my limitedTagTaskProperties(tagItem, searchScope, resultLimit)
	end if
	
	return my tagTaskPropertiesToJSON(tagId, tagName, searchScope, resultLimit, taskProperties, includeExactCount)
end tagTasksToJSON

on exactTagTaskProperties(tagItem, searchScope)
	tell application id (omniFocusAppID as text)
		if searchScope is "all" then return properties of every task of tagItem
		if searchScope is "completed" then return properties of every task of tagItem where «property FCce» is true
		if searchScope is "remaining" then return properties of every task of tagItem where «property FCce» is false and «property FC-e» is false
		if searchScope is "available" then return properties of every task of tagItem where «property FCce» is false and «property FC-e» is false and blocked is false
		if searchScope is "inbox" then return properties of every task of tagItem where «property FCIi» is true and completed is false
		if searchScope is "flagged" then return properties of every task of tagItem where «property FCce» is false and «property FC-e» is false and flagged is true
		if searchScope is "due" then return properties of every task of tagItem where «property FCce» is false and «property FC-e» is false and «property FCDd» is not missing value
		if searchScope is "deferred" then return properties of every task of tagItem where «property FCce» is false and «property FC-e» is false and «property FCDs» is not missing value
	end tell
	error "Unknown tag task scope '" & searchScope & "'. Use remaining, available, inbox, flagged, due, deferred, completed, or all."
end exactTagTaskProperties

on limitedTagTaskProperties(tagItem, searchScope, resultLimit)
	set fetchLimit to resultLimit + 1
	tell application id (omniFocusAppID as text)
		try
			if searchScope is "all" then return properties of task 1 thru fetchLimit of tagItem
			if searchScope is "completed" then return properties of task 1 thru fetchLimit of tagItem where «property FCce» is true
			if searchScope is "remaining" then return properties of task 1 thru fetchLimit of tagItem where «property FCce» is false and «property FC-e» is false
			if searchScope is "available" then return properties of task 1 thru fetchLimit of tagItem where «property FCce» is false and «property FC-e» is false and blocked is false
			if searchScope is "inbox" then return properties of task 1 thru fetchLimit of tagItem where «property FCIi» is true and completed is false
			if searchScope is "flagged" then return properties of task 1 thru fetchLimit of tagItem where «property FCce» is false and «property FC-e» is false and flagged is true
			if searchScope is "due" then return properties of task 1 thru fetchLimit of tagItem where «property FCce» is false and «property FC-e» is false and «property FCDd» is not missing value
			if searchScope is "deferred" then return properties of task 1 thru fetchLimit of tagItem where «property FCce» is false and «property FC-e» is false and «property FCDs» is not missing value
		on error
			return my exactTagTaskProperties(tagItem, searchScope)
		end try
	end tell
	error "Unknown tag task scope '" & searchScope & "'. Use remaining, available, inbox, flagged, due, deferred, completed, or all."
end limitedTagTaskProperties

on tagTaskPropertiesToJSON(tagId, tagName, searchScope, resultLimit, taskProperties, includeExactCount)
	set taskCount to count of taskProperties
	set emitCount to taskCount
	if resultLimit is not -1 and emitCount > resultLimit then set emitCount to resultLimit
	set hasMore to false
	if resultLimit is not -1 and taskCount > resultLimit then set hasMore to true
	
	set jsonItems to {}
	repeat with taskIndex from 1 to emitCount
		set taskPropertiesItem to item taskIndex of taskProperties
		set end of jsonItems to my taskPropertiesToJSON(taskPropertiesItem)
	end repeat
	
	set taskCountJSON to "null"
	if includeExactCount then set taskCountJSON to taskCount as text
	return "{\"tag\":{" & my quoteKeyValue("id", tagId) & "," & my quoteKeyValue("name", tagName) & "},\"scope\":\"" & my escapeJSON(searchScope) & "\",\"count\":" & taskCountJSON & ",\"hasMore\":" & my boolJSONValue(hasMore) & ",\"limit\":" & my limitJSONValue(resultLimit) & ",\"tasks\":[" & my joinText(jsonItems, ",") & "]}"
end tagTaskPropertiesToJSON

on projectPropertiesMatchesQuery(projectPropertiesItem, searchQuery)
	if my textContains(id of projectPropertiesItem, searchQuery) then return true
	if my textContains(name of projectPropertiesItem, searchQuery) then return true
	if my textContains(note of projectPropertiesItem, searchQuery) then return true
	if my textContains(status of projectPropertiesItem as text, searchQuery) then return true
	return false
end projectPropertiesMatchesQuery

on folderPropertiesMatchesQuery(folderPropertiesItem, searchQuery)
	if my textContains(id of folderPropertiesItem, searchQuery) then return true
	if my textContains(name of folderPropertiesItem, searchQuery) then return true
	if my textContains(note of folderPropertiesItem, searchQuery) then return true
	return false
end folderPropertiesMatchesQuery

on tagPropertiesMatchesQuery(tagPropertiesItem, searchQuery)
	if my textContains(id of tagPropertiesItem, searchQuery) then return true
	if my textContains(name of tagPropertiesItem, searchQuery) then return true
	if my textContains(note of tagPropertiesItem, searchQuery) then return true
	return false
end tagPropertiesMatchesQuery

on textContains(rawText, searchQuery)
	ignoring case
		if (my safeValue(rawText)) contains searchQuery then return true
	end ignoring
	return false
end textContains

on warnFullTextSearch(searchMode, searchQuery, searchScope)
	set warningText to "[omnifocus-warning] full-text-search mode=" & searchMode & " query=\"" & searchQuery & "\""
	if searchScope is not "" then set warningText to warningText & " scope=" & searchScope
	set warningText to warningText & " Prefer a narrower command when possible."
	log warningText
end warnFullTextSearch

on bulkTaskListToJSON(requestedMode, optionsMap)
	set resultLimit to my listLimitValue(optionsMap, 50)
	set includeExactCount to false
	if my hasOption(optionsMap, "count") then set includeExactCount to my boolValue(my optionValue(optionsMap, "count"))
	if includeExactCount or resultLimit is -1 then return my exactBulkTaskListToJSON(requestedMode, resultLimit)
	return my limitedBulkTaskListToJSON(requestedMode, resultLimit)
end bulkTaskListToJSON

on exactBulkTaskListToJSON(requestedMode, resultLimit)
	
	tell application id (omniFocusAppID as text)
		tell front document
			if requestedMode is "tasks-inbox" then
				set taskProperties to properties of every «class FCit» where completed is false
			else if requestedMode is "tasks-available" then
				set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and blocked is false
			else if requestedMode is "tasks-remaining" then
				set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false
			else if requestedMode is "tasks-flagged" then
				set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and flagged is true
			else if requestedMode is "tasks-due" then
				set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and «property FCDd» is not missing value
			else if requestedMode is "tasks-deferred" then
				set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and «property FCDs» is not missing value
			else if requestedMode is "tasks-completed" then
				set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is true
			else
				error "Unknown task list mode '" & requestedMode & "'."
			end if
		end tell
	end tell
	
	return my bulkTaskPropertiesToJSON(requestedMode, resultLimit, taskProperties, true)
end exactBulkTaskListToJSON

on limitedBulkTaskListToJSON(requestedMode, resultLimit)
	set fetchLimit to resultLimit + 1
	
	tell application id (omniFocusAppID as text)
		tell front document
			try
				if requestedMode is "tasks-inbox" then
					set taskProperties to properties of «class FCit» 1 thru fetchLimit where completed is false
				else if requestedMode is "tasks-available" then
					set taskProperties to properties of «class FCft» 1 thru fetchLimit where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and blocked is false
				else if requestedMode is "tasks-remaining" then
					set taskProperties to properties of «class FCft» 1 thru fetchLimit where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false
				else if requestedMode is "tasks-flagged" then
					set taskProperties to properties of «class FCft» 1 thru fetchLimit where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and flagged is true
				else if requestedMode is "tasks-due" then
					set taskProperties to properties of «class FCft» 1 thru fetchLimit where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and «property FCDd» is not missing value
				else if requestedMode is "tasks-deferred" then
					set taskProperties to properties of «class FCft» 1 thru fetchLimit where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and «property FCDs» is not missing value
				else if requestedMode is "tasks-completed" then
					set taskProperties to properties of «class FCft» 1 thru fetchLimit where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is true
				else
					error "Unknown task list mode '" & requestedMode & "'."
				end if
			on error
				if requestedMode is "tasks-inbox" then
					set taskProperties to properties of every «class FCit» where completed is false
				else if requestedMode is "tasks-available" then
					set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and blocked is false
				else if requestedMode is "tasks-remaining" then
					set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false
				else if requestedMode is "tasks-flagged" then
					set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and flagged is true
				else if requestedMode is "tasks-due" then
					set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and «property FCDd» is not missing value
				else if requestedMode is "tasks-deferred" then
					set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is false and «property FC-e» is false and «property FCDs» is not missing value
				else if requestedMode is "tasks-completed" then
					set taskProperties to properties of every «class FCft» where («property FCPr» is missing value or id is not id of «property FCPr») and «property FCce» is true
				else
					error "Unknown task list mode '" & requestedMode & "'."
				end if
			end try
		end tell
	end tell
	
	return my bulkTaskPropertiesToJSON(requestedMode, resultLimit, taskProperties, false)
end limitedBulkTaskListToJSON

on bulkTaskPropertiesToJSON(requestedMode, resultLimit, taskProperties, includeExactCount)
	set taskCount to count of taskProperties
	set emitCount to taskCount
	if resultLimit is not -1 and emitCount > resultLimit then set emitCount to resultLimit
	set hasMore to false
	if resultLimit is not -1 and taskCount > resultLimit then set hasMore to true
	
	set jsonItems to {}
	repeat with taskIndex from 1 to emitCount
		set taskPropertiesItem to item taskIndex of taskProperties
		set end of jsonItems to my taskPropertiesToJSON(taskPropertiesItem)
	end repeat
	
	set taskCountJSON to "null"
	if includeExactCount then set taskCountJSON to taskCount as text
	return "{\"mode\":\"" & my escapeJSON(requestedMode) & "\",\"count\":" & taskCountJSON & ",\"hasMore\":" & my boolJSONValue(hasMore) & ",\"limit\":" & my limitJSONValue(resultLimit) & ",\"tasks\":[" & my joinText(jsonItems, ",") & "]}"
end bulkTaskPropertiesToJSON

on taskPropertiesToJSON(taskPropertiesItem)
	return "{" & ¬
		my quoteKeyValue("id", id of taskPropertiesItem) & "," & ¬
		my quoteKeyValue("name", name of taskPropertiesItem) & "," & ¬
		my boolKeyValue("flagged", flagged of taskPropertiesItem) & "," & ¬
		my boolKeyValue("completed", completed of taskPropertiesItem) & "," & ¬
		my boolKeyValue("effectivelyCompleted", effectively completed of taskPropertiesItem) & "," & ¬
		my boolKeyValue("effectivelyDropped", effectively dropped of taskPropertiesItem) & "," & ¬
		my quoteKeyValue("due", my dateValue(due date of taskPropertiesItem)) & "," & ¬
		my quoteKeyValue("defer", my dateValue(defer date of taskPropertiesItem)) & ¬
		"}"
end taskPropertiesToJSON

on projectPropertiesToJSON(projectPropertiesItem)
	return "{" & ¬
		my quoteKeyValue("id", id of projectPropertiesItem) & "," & ¬
		my quoteKeyValue("name", name of projectPropertiesItem) & "," & ¬
		my quoteKeyValue("status", my safeValue(status of projectPropertiesItem as text)) & "," & ¬
		my boolKeyValue("completed", completed of projectPropertiesItem) & "," & ¬
		my quoteKeyValue("due", my dateValue(due date of projectPropertiesItem)) & "," & ¬
		my quoteKeyValue("defer", my dateValue(defer date of projectPropertiesItem)) & "," & ¬
		my quoteKeyValue("note", note of projectPropertiesItem) & ¬
		"}"
end projectPropertiesToJSON

on folderPropertiesToJSON(folderPropertiesItem)
	return "{" & ¬
		my quoteKeyValue("id", id of folderPropertiesItem) & "," & ¬
		my quoteKeyValue("name", name of folderPropertiesItem) & "," & ¬
		my boolKeyValue("hidden", hidden of folderPropertiesItem) & "," & ¬
		my quoteKeyValue("note", note of folderPropertiesItem) & ¬
		"}"
end folderPropertiesToJSON

on tagPropertiesToJSON(tagPropertiesItem)
	return "{" & ¬
		my quoteKeyValue("id", id of tagPropertiesItem) & "," & ¬
		my quoteKeyValue("name", name of tagPropertiesItem) & "," & ¬
		my boolKeyValue("allowsNextAction", «property FCNA» of tagPropertiesItem) & "," & ¬
		my boolKeyValue("hidden", hidden of tagPropertiesItem) & "," & ¬
		"\"availableTaskCount\":" & my numberValue(«property FCa#» of tagPropertiesItem) & "," & ¬
		"\"remainingTaskCount\":" & my numberValue(«property FCr#» of tagPropertiesItem) & "," & ¬
		my quoteKeyValue("note", note of tagPropertiesItem) & ¬
		"}"
end tagPropertiesToJSON

on projectsToJSON(projectPropertiesItems, optionsMap)
	set projectScope to my optionValue(optionsMap, "scope")
	if projectScope is "" then set projectScope to "remaining"
	
	set jsonItems to {}
	repeat with projectPropertiesItem in projectPropertiesItems
		if my shouldIncludeProjectProperties(projectPropertiesItem, projectScope) then set end of jsonItems to my projectPropertiesToJSON(projectPropertiesItem)
	end repeat
	return "[" & my joinText(jsonItems, ",") & "]"
end projectsToJSON

on foldersToJSON(folderPropertiesItems)
	set jsonItems to {}
	repeat with folderPropertiesItem in folderPropertiesItems
		set end of jsonItems to my folderPropertiesToJSON(folderPropertiesItem)
	end repeat
	return "[" & my joinText(jsonItems, ",") & "]"
end foldersToJSON

on tagsToJSON(tagPropertiesItems)
	set jsonItems to {}
	repeat with tagPropertiesItem in tagPropertiesItems
		set end of jsonItems to my tagPropertiesToJSON(tagPropertiesItem)
	end repeat
	return "[" & my joinText(jsonItems, ",") & "]"
end tagsToJSON

on isProjectRootTask(taskItem)
	tell application id (omniFocusAppID as text)
		tell taskItem
			try
				set containingProject to «property FCPr»
				if containingProject is missing value then return false
				return id is id of containingProject
			on error
				return false
			end try
		end tell
	end tell
end isProjectRootTask

on shouldIncludeTask(taskItem, requestedMode)
	tell application id (omniFocusAppID as text)
		tell taskItem
			if my isProjectRootTask(taskItem) then return false
			if requestedMode is "completed" then return «property FCce»
			if «property FCce» then return false
			if «property FC-e» then return false
			if requestedMode is "inbox" then return true
			if requestedMode is "remaining" then return true
			if requestedMode is "available" then return not blocked
			if requestedMode is "flagged" then return flagged
			if requestedMode is "due" then return «property FCDd» is not missing value
			if requestedMode is "deferred" then return «property FCDs» is not missing value
		end tell
	end tell
	return false
end shouldIncludeTask

on shouldIncludeProject(projectItem, projectScope)
	tell application id (omniFocusAppID as text)
		tell projectItem
			if projectScope is "all" then return true
			if projectScope is "completed" or projectScope is "done" then return completed
			if projectScope is "dropped" then return «property FC-d»
			if projectScope is "on-hold" or projectScope is "on hold" then return status is on hold status
			if projectScope is "active" then return status is active status
			if projectScope is "remaining" then return completed is false
		end tell
	end tell
	error "Unknown project scope '" & projectScope & "'. Use remaining, active, on-hold, completed, dropped, or all."
end shouldIncludeProject

on shouldIncludeProjectProperties(projectPropertiesItem, projectScope)
	if projectScope is "all" then return true
	if projectScope is "completed" or projectScope is "done" then return completed of projectPropertiesItem
	if projectScope is "dropped" then return «property FC-d» of projectPropertiesItem
	if projectScope is "on-hold" or projectScope is "on hold" then return status of projectPropertiesItem is on hold status
	if projectScope is "active" then return status of projectPropertiesItem is active status
	if projectScope is "remaining" then return completed of projectPropertiesItem is false
	error "Unknown project scope '" & projectScope & "'. Use remaining, active, on-hold, completed, dropped, or all."
end shouldIncludeProjectProperties

on operationToJSON(operationName, taskItem)
	return "{\"ok\":true,\"operation\":\"" & operationName & "\",\"task\":" & my detailTaskToJSON(taskItem) & "}"
end operationToJSON

on projectOperationToJSON(operationName, projectItem)
	return "{\"ok\":true,\"operation\":\"" & operationName & "\",\"project\":" & my detailProjectToJSON(projectItem) & "}"
end projectOperationToJSON

on folderOperationToJSON(operationName, folderItem)
	return "{\"ok\":true,\"operation\":\"" & operationName & "\",\"folder\":" & my detailFolderToJSON(folderItem) & "}"
end folderOperationToJSON

on tagOperationToJSON(operationName, tagItem)
	return "{\"ok\":true,\"operation\":\"" & operationName & "\",\"tag\":" & my detailTagToJSON(tagItem) & "}"
end tagOperationToJSON

on taskToJSON(taskItem)
	tell application id (omniFocusAppID as text)
		tell taskItem
			set taskId to my safeValue(id)
			set taskName to my safeValue(name)
			set taskNote to my safeValue(note)
			set taskFlagged to flagged
			set taskCompleted to completed
			set taskDue to my dateValue(«property FCDd»)
			set taskDefer to my dateValue(«property FCDs»)
			set taskEstimate to my numberValue(«property FCEM»)
			
			set projectName to ""
			set folderName to ""
			try
				set containingProject to «property FCPr»
				if containingProject is not missing value then
					set projectName to my safeValue(name of containingProject)
					try
						set containingFolder to folder of containingProject
						if containingFolder is not missing value then set folderName to my safeValue(name of containingFolder)
					end try
				end if
			end try
			
			set contextName to ""
			try
				if «property FCpt» is not missing value then set contextName to my safeValue(name of «property FCpt»)
			end try
		end tell
	end tell
	
	return "{" & ¬
		my quoteKeyValue("id", taskId) & "," & ¬
		my quoteKeyValue("name", taskName) & "," & ¬
		my quoteKeyValue("project", projectName) & "," & ¬
		my quoteKeyValue("folder", folderName) & "," & ¬
		my quoteKeyValue("context", contextName) & "," & ¬
		my boolKeyValue("flagged", taskFlagged) & "," & ¬
		my boolKeyValue("completed", taskCompleted) & "," & ¬
		my quoteKeyValue("due", taskDue) & "," & ¬
		my quoteKeyValue("defer", taskDefer) & "," & ¬
		"\"estimatedMinutes\":" & taskEstimate & "," & ¬
		my quoteKeyValue("note", taskNote) & ¬
		"}"
end taskToJSON

on detailTaskToJSON(taskItem)
	tell application id (omniFocusAppID as text)
		tell taskItem
			set baseJSON to my taskToJSON(taskItem)
			set taskBlocked to blocked
			set taskNext to next
			set taskInInbox to «property FCIi»
			set taskDropped to «property FC-d»
			set taskEffectivelyCompleted to «property FCce»
			set taskEffectivelyDropped to «property FC-e»
			set taskCreated to my dateValue(«property FCDa»)
			set taskModified to my dateValue(«property FCDm»)
			set taskCompletedDate to my dateValue(«property FCdc»)
			set taskEffectiveDue to my dateValue(«property FCde»)
			set taskEffectiveDefer to my dateValue(«property FCse»)
			set taskChildren to my numberValue(number of tasks)
			
			set parentName to ""
			try
				if «property FCPt» is not missing value then set parentName to my safeValue(name of «property FCPt»)
			end try
			
			set tagNames to {}
			try
				repeat with tagItem in tags
					set end of tagNames to "\"" & my escapeJSON(name of tagItem as text) & "\""
				end repeat
			end try
		end tell
	end tell
	
	set baseWithoutClose to text 1 thru -2 of baseJSON
	return baseWithoutClose & "," & ¬
		my boolKeyValue("blocked", taskBlocked) & "," & ¬
		my boolKeyValue("next", taskNext) & "," & ¬
		my boolKeyValue("inInbox", taskInInbox) & "," & ¬
		my boolKeyValue("dropped", taskDropped) & "," & ¬
		my boolKeyValue("effectivelyCompleted", taskEffectivelyCompleted) & "," & ¬
		my boolKeyValue("effectivelyDropped", taskEffectivelyDropped) & "," & ¬
		my quoteKeyValue("created", taskCreated) & "," & ¬
		my quoteKeyValue("modified", taskModified) & "," & ¬
		my quoteKeyValue("completedDate", taskCompletedDate) & "," & ¬
		my quoteKeyValue("effectiveDue", taskEffectiveDue) & "," & ¬
		my quoteKeyValue("effectiveDefer", taskEffectiveDefer) & "," & ¬
		my quoteKeyValue("parent", parentName) & "," & ¬
		"\"childCount\":" & taskChildren & "," & ¬
		"\"tags\":[" & my joinText(tagNames, ",") & "]" & ¬
		"}"
end detailTaskToJSON

on projectToJSON(projectItem)
	tell application id (omniFocusAppID as text)
		tell projectItem
			set projectId to my safeValue(id)
			set projectName to my safeValue(name)
			set projectNote to my safeValue(note)
			set projectCompleted to completed
			set projectDue to my dateValue(«property FCDd»)
			set projectDefer to my dateValue(«property FCDs»)
			set projectStatus to my safeValue(status as text)
			
			set folderName to ""
			try
				if folder is not missing value then set folderName to my safeValue(name of folder)
			end try
		end tell
	end tell
	
	return "{" & ¬
		my quoteKeyValue("id", projectId) & "," & ¬
		my quoteKeyValue("name", projectName) & "," & ¬
		my quoteKeyValue("folder", folderName) & "," & ¬
		my quoteKeyValue("status", projectStatus) & "," & ¬
		my boolKeyValue("completed", projectCompleted) & "," & ¬
		my quoteKeyValue("due", projectDue) & "," & ¬
		my quoteKeyValue("defer", projectDefer) & "," & ¬
		my quoteKeyValue("note", projectNote) & ¬
		"}"
end projectToJSON

on folderToJSON(folderItem)
	tell application id (omniFocusAppID as text)
		tell folderItem
			set folderId to my safeValue(id)
			set folderName to my safeValue(name)
			set folderNote to my safeValue(note)
			set folderHidden to hidden
			
			set parentName to ""
			try
				set parentItem to container
				if parentItem is not missing value then set parentName to my safeValue(name of parentItem)
			end try
		end tell
	end tell
	
	return "{" & ¬
		my quoteKeyValue("id", folderId) & "," & ¬
		my quoteKeyValue("name", folderName) & "," & ¬
		my quoteKeyValue("parent", parentName) & "," & ¬
		my boolKeyValue("hidden", folderHidden) & "," & ¬
		my quoteKeyValue("note", folderNote) & ¬
		"}"
end folderToJSON

on tagToJSON(tagItem)
	tell application id (omniFocusAppID as text)
		tell tagItem
			set tagId to my safeValue(id)
			set tagName to my safeValue(name)
			set tagNote to my safeValue(note)
			set tagAllowsNext to «property FCNA»
			set tagHidden to hidden
			set tagAvailableCount to my numberValue(«property FCa#»)
			set tagRemainingCount to my numberValue(«property FCr#»)
			
			set parentName to ""
			try
				if container is not missing value then set parentName to my safeValue(name of container)
			end try
		end tell
	end tell
	
	return "{" & ¬
		my quoteKeyValue("id", tagId) & "," & ¬
		my quoteKeyValue("name", tagName) & "," & ¬
		my quoteKeyValue("parent", parentName) & "," & ¬
		my boolKeyValue("allowsNextAction", tagAllowsNext) & "," & ¬
		my boolKeyValue("hidden", tagHidden) & "," & ¬
		"\"availableTaskCount\":" & tagAvailableCount & "," & ¬
		"\"remainingTaskCount\":" & tagRemainingCount & "," & ¬
		my quoteKeyValue("note", tagNote) & ¬
		"}"
end tagToJSON

on detailProjectToJSON(projectItem)
	tell application id (omniFocusAppID as text)
		tell projectItem
			set baseJSON to my projectToJSON(projectItem)
			set projectFlagged to flagged
			set projectBlocked to blocked
			set projectSequential to sequential
			set projectCompletedByChildren to «property FCbc»
			set projectDropped to «property FC-d»
			set projectEffectivelyCompleted to «property FCce»
			set projectEffectivelyDropped to «property FC-e»
			set projectCreated to my dateValue(«property FCDa»)
			set projectModified to my dateValue(«property FCDm»)
			set projectCompletedDate to my dateValue(«property FCdc»)
			set projectEffectiveDue to my dateValue(«property FCde»)
			set projectEffectiveDefer to my dateValue(«property FCse»)
			set projectEstimate to my numberValue(«property FCEM»)
			set projectTaskCount to my numberValue(«property FC#t»)
			set projectAvailableTaskCount to my numberValue(«property FC#a»)
			set projectCompletedTaskCount to my numberValue(«property FC#c»)
			
			set tagName to ""
			try
				if «property FCpt» is not missing value then set tagName to my safeValue(name of «property FCpt»)
			end try
			
			set tagNames to {}
			try
				repeat with tagItem in tags
					set end of tagNames to "\"" & my escapeJSON(name of tagItem as text) & "\""
				end repeat
			end try
		end tell
	end tell
	
	set baseWithoutClose to text 1 thru -2 of baseJSON
	return baseWithoutClose & "," & ¬
		my boolKeyValue("flagged", projectFlagged) & "," & ¬
		my boolKeyValue("blocked", projectBlocked) & "," & ¬
		my boolKeyValue("sequential", projectSequential) & "," & ¬
		my boolKeyValue("completedByChildren", projectCompletedByChildren) & "," & ¬
		my boolKeyValue("dropped", projectDropped) & "," & ¬
		my boolKeyValue("effectivelyCompleted", projectEffectivelyCompleted) & "," & ¬
		my boolKeyValue("effectivelyDropped", projectEffectivelyDropped) & "," & ¬
		my quoteKeyValue("created", projectCreated) & "," & ¬
		my quoteKeyValue("modified", projectModified) & "," & ¬
		my quoteKeyValue("completedDate", projectCompletedDate) & "," & ¬
		my quoteKeyValue("effectiveDue", projectEffectiveDue) & "," & ¬
		my quoteKeyValue("effectiveDefer", projectEffectiveDefer) & "," & ¬
		"\"estimatedMinutes\":" & projectEstimate & "," & ¬
		"\"taskCount\":" & projectTaskCount & "," & ¬
		"\"availableTaskCount\":" & projectAvailableTaskCount & "," & ¬
		"\"completedTaskCount\":" & projectCompletedTaskCount & "," & ¬
		my quoteKeyValue("tag", tagName) & "," & ¬
		"\"tags\":[" & my joinText(tagNames, ",") & "]" & ¬
		"}"
end detailProjectToJSON

on detailFolderToJSON(folderItem)
	tell application id (omniFocusAppID as text)
		tell folderItem
			set baseJSON to my folderToJSON(folderItem)
			set folderEffectivelyHidden to «property FCHe»
			set folderCreated to my dateValue(«property FCDa»)
			set folderModified to my dateValue(«property FCDm»)
			set folderCount to my numberValue(number of folders)
			set projectCount to my numberValue(number of projects)
		end tell
	end tell
	
	set baseWithoutClose to text 1 thru -2 of baseJSON
	return baseWithoutClose & "," & ¬
		my boolKeyValue("effectivelyHidden", folderEffectivelyHidden) & "," & ¬
		my quoteKeyValue("created", folderCreated) & "," & ¬
		my quoteKeyValue("modified", folderModified) & "," & ¬
		"\"folderCount\":" & folderCount & "," & ¬
		"\"projectCount\":" & projectCount & ¬
		"}"
end detailFolderToJSON

on detailTagToJSON(tagItem)
	tell application id (omniFocusAppID as text)
		tell tagItem
			set baseJSON to my tagToJSON(tagItem)
			set tagEffectivelyHidden to «property FCHe»
			set childCount to my numberValue(number of tags)
		end tell
	end tell
	
	set baseWithoutClose to text 1 thru -2 of baseJSON
	return baseWithoutClose & "," & ¬
		my boolKeyValue("effectivelyHidden", tagEffectivelyHidden) & "," & ¬
		"\"childCount\":" & childCount & ¬
		"}"
end detailTagToJSON

on parseOptions(argv, startIndex)
	set optionsMap to {}
	if (count of argv) < startIndex then return optionsMap
	repeat with argIndex from startIndex to count of argv
		set rawArg to item argIndex of argv as text
		set oldDelimiters to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "="
		set argParts to text items of rawArg
		set AppleScript's text item delimiters to oldDelimiters
		if (count of argParts) < 2 then
			if argIndex is startIndex then set end of optionsMap to {"name", my unquote(rawArg)}
		else
			set optionKey to item 1 of argParts
			set optionValueParts to items 2 thru -1 of argParts
			set optionValueText to my joinText(optionValueParts, "=")
			set end of optionsMap to {optionKey, my unquote(optionValueText)}
		end if
	end repeat
	return optionsMap
end parseOptions

on hasOption(optionsMap, optionKey)
	repeat with optionPair in optionsMap
		if item 1 of optionPair is optionKey then return true
	end repeat
	return false
end hasOption

on optionValue(optionsMap, optionKey)
	repeat with optionPair in optionsMap
		if item 1 of optionPair is optionKey then return item 2 of optionPair
	end repeat
	return ""
end optionValue

on unquote(rawText)
	set cleanText to rawText as text
	if (length of cleanText) > 1 then
		if (text 1 of cleanText is "\"" and text -1 of cleanText is "\"") then return text 2 thru -2 of cleanText
		if (text 1 of cleanText is "'" and text -1 of cleanText is "'") then return text 2 thru -2 of cleanText
	end if
	return cleanText
end unquote

on boolValue(rawText)
	if rawText is true then return true
	if rawText is false then return false
	set valueText to rawText as text
	if valueText is "true" then return true
	if valueText is "yes" then return true
	if valueText is "1" then return true
	if valueText is "false" then return false
	if valueText is "no" then return false
	if valueText is "0" then return false
	error "Expected boolean value, got '" & valueText & "'."
end boolValue

on intValue(rawText)
	try
		return rawText as integer
	on error
		error "Expected integer value, got '" & rawText & "'."
	end try
end intValue

on listLimitValue(optionsMap, defaultLimit)
	if not my hasOption(optionsMap, "limit") then return defaultLimit
	set rawLimit to my optionValue(optionsMap, "limit")
	if rawLimit is "all" then return -1
	if rawLimit is "none" then return -1
	set parsedLimit to my intValue(rawLimit)
	if parsedLimit < 1 then return -1
	return parsedLimit
end listLimitValue

on limitJSONValue(resultLimit)
	if resultLimit is -1 then return "null"
	return resultLimit as text
end limitJSONValue

on optionalDateValue(rawText)
	if rawText is "" then return missing value
	if rawText is "none" then return missing value
	if rawText is "null" then return missing value
	try
		return date rawText
	on error
		error "Could not parse date '" & rawText & "'. Use a date format understood by macOS in the current locale."
	end try
end optionalDateValue

on quoteKeyValue(keyName, rawValue)
	return "\"" & keyName & "\":\"" & my escapeJSON(rawValue as text) & "\""
end quoteKeyValue

on boolKeyValue(keyName, rawValue)
	if rawValue then
		return "\"" & keyName & "\":true"
	else
		return "\"" & keyName & "\":false"
	end if
end boolKeyValue

on boolJSONValue(rawValue)
	if rawValue then return "true"
	return "false"
end boolJSONValue

on safeValue(rawValue)
	if rawValue is missing value then return ""
	return rawValue as text
end safeValue

on numberValue(rawValue)
	if rawValue is missing value then return "0"
	try
		return rawValue as integer as text
	on error
		return "0"
	end try
end numberValue

on dateValue(rawValue)
	if rawValue is missing value then return ""
	try
		return rawValue as text
	on error
		return ""
	end try
end dateValue

on escapeJSON(rawText)
	set escapedText to rawText
	set escapedText to my replaceText("\\", "\\\\", escapedText)
	set escapedText to my replaceText("\"", "\\\"", escapedText)
	set escapedText to my replaceText(return, "\\n", escapedText)
	set escapedText to my replaceText(linefeed, "\\n", escapedText)
	set escapedText to my replaceText(tab, "\\t", escapedText)
	return escapedText
end escapeJSON

on replaceText(searchText, replacementText, sourceText)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to searchText
	set textItems to text items of sourceText
	set AppleScript's text item delimiters to replacementText
	set replacedText to textItems as text
	set AppleScript's text item delimiters to oldDelimiters
	return replacedText
end replaceText

on trimText(rawText)
	set cleanText to rawText as text
	repeat while cleanText starts with " "
		if (length of cleanText) is 1 then return ""
		set cleanText to text 2 thru -1 of cleanText
	end repeat
	repeat while cleanText ends with " "
		if (length of cleanText) is 1 then return ""
		set cleanText to text 1 thru -2 of cleanText
	end repeat
	return cleanText
end trimText

on splitList(rawText)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ","
	set rawItems to text items of (rawText as text)
	set AppleScript's text item delimiters to oldDelimiters
	set cleanItems to {}
	repeat with rawItem in rawItems
		set cleanItem to my trimText(rawItem as text)
		if cleanItem is not "" then set end of cleanItems to cleanItem
	end repeat
	return cleanItems
end splitList

on joinText(textItems, delimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set joinedText to textItems as text
	set AppleScript's text item delimiters to oldDelimiters
	return joinedText
end joinText

end using terms from
