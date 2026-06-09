on run argv
	set requestedMode to "remaining"
	if (count of argv) > 0 then set requestedMode to item 1 of argv
	
	set validModes to {"inbox", "available", "remaining", "flagged", "due", "deferred", "completed", "projects", "search", "detail", "create", "update", "delete"}
	if validModes does not contain requestedMode then
		error "Unknown mode '" & requestedMode & "'. Use one of: inbox, available, remaining, flagged, due, deferred, completed, projects, search, detail, create, update, delete."
	end if
	
	tell application "/Applications/OmniFocus.app"
		tell front document
			if requestedMode is "projects" then
				set projectItems to every «class FCfx»
				return my projectsToJSON(projectItems)
			else if requestedMode is "search" then
				set optionsMap to my parseOptions(argv, 2)
				return my searchTasksToJSON(optionsMap)
			else if requestedMode is "detail" then
				if (count of argv) < 2 then error "detail requires a task id."
				set taskItem to my findTaskByID(item 2 of argv)
				return my detailTaskToJSON(taskItem)
			else if requestedMode is "create" then
				set optionsMap to my parseOptions(argv, 2)
				set taskItem to my createTask(optionsMap)
				return my operationToJSON("created", taskItem)
			else if requestedMode is "update" then
				if (count of argv) < 2 then error "update requires a task id."
				set taskItem to my findTaskByID(item 2 of argv)
				set optionsMap to my parseOptions(argv, 3)
				my updateTask(taskItem, optionsMap)
				return my operationToJSON("updated", taskItem)
			else if requestedMode is "delete" then
				if (count of argv) < 2 then error "delete requires a task id."
				set taskItem to my findTaskByID(item 2 of argv)
				set deletedTaskJSON to my taskToJSON(taskItem)
				delete taskItem
				return "{\"ok\":true,\"operation\":\"deleted\",\"task\":" & deletedTaskJSON & "}"
			else
				if requestedMode is "inbox" then
					set taskItems to every «class FCit»
				else
					set taskItems to every «class FCft»
				end if
				
				return my tasksToJSON(taskItems, requestedMode)
			end if
		end tell
	end tell
end run

on createTask(optionsMap)
	set taskName to my optionValue(optionsMap, "name")
	if taskName is "" then set taskName to my optionValue(optionsMap, "title")
	if taskName is "" then error "create requires name=<task title>."
	
	tell application "/Applications/OmniFocus.app"
		tell front document
			set projectName to my optionValue(optionsMap, "project")
			if projectName is not "" then
				set targetProject to my findProject(projectName)
				set taskItem to make new «class FCac» at end of tasks of targetProject with properties {name:taskName}
			else
				set taskItem to make new «class FCit» with properties {name:taskName}
			end if
		end tell
	end tell
	
	my updateTask(taskItem, optionsMap)
	return taskItem
end createTask

on updateTask(taskItem, optionsMap)
	tell application "/Applications/OmniFocus.app"
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
				set «property FCpt» of taskItem to my findTag(tagName)
			end if
		end if
		
		if my hasOption(optionsMap, "project") then
			set projectName to my optionValue(optionsMap, "project")
			if projectName is not "" then
				set targetProject to my findProject(projectName)
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

on findTaskByID(taskID)
	tell application "/Applications/OmniFocus.app"
		tell front document
			set taskItems to every «class FCft»
			repeat with taskItem in taskItems
				if id of taskItem is taskID then return taskItem
			end repeat
			set inboxItems to every «class FCit»
			repeat with taskItem in inboxItems
				if id of taskItem is taskID then return taskItem
			end repeat
		end tell
	end tell
	error "No OmniFocus task found with id '" & taskID & "'."
end findTaskByID

on findProject(projectNameOrID)
	tell application "/Applications/OmniFocus.app"
		tell front document
			set projectItems to every «class FCfx»
			repeat with projectItem in projectItems
				if id of projectItem is projectNameOrID then return projectItem
				if name of projectItem is projectNameOrID then return projectItem
			end repeat
		end tell
	end tell
	error "No OmniFocus project found with id or name '" & projectNameOrID & "'."
end findProject

on findTag(tagNameOrID)
	tell application "/Applications/OmniFocus.app"
		tell front document
			set tagItems to every «class FCfc»
			repeat with tagItem in tagItems
				if id of tagItem is tagNameOrID then return tagItem
				if name of tagItem is tagNameOrID then return tagItem
			end repeat
		end tell
	end tell
	error "No OmniFocus tag found with id or name '" & tagNameOrID & "'."
end findTag

on searchTasksToJSON(optionsMap)
	set searchQuery to my optionValue(optionsMap, "query")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "q")
	if searchQuery is "" then set searchQuery to my optionValue(optionsMap, "name")
	if searchQuery is "" then error "search requires query=<text>."
	
	set searchScope to my optionValue(optionsMap, "scope")
	if searchScope is "" then set searchScope to "remaining"
	
	set includeDetails to false
	if my hasOption(optionsMap, "detail") then set includeDetails to my boolValue(my optionValue(optionsMap, "detail"))
	
	set resultLimit to 50
	if my hasOption(optionsMap, "limit") then set resultLimit to my intValue(my optionValue(optionsMap, "limit"))
	if resultLimit < 1 then set resultLimit to 1
	
	tell application "/Applications/OmniFocus.app"
		tell front document
			if searchScope is "inbox" then
				set taskItems to every «class FCit»
			else
				set taskItems to every «class FCft»
			end if
		end tell
	end tell
	
	set jsonItems to {}
	set matchedCount to 0
	repeat with taskItem in taskItems
		if my shouldIncludeTaskForSearch(taskItem, searchScope) then
			if my taskMatchesQuery(taskItem, searchQuery) then
				set matchedCount to matchedCount + 1
				if matchedCount ≤ resultLimit then
					if includeDetails then
						set end of jsonItems to my detailTaskToJSON(taskItem)
					else
						set end of jsonItems to my taskToJSON(taskItem)
					end if
				end if
			end if
		end if
	end repeat
	
	return "{\"query\":\"" & my escapeJSON(searchQuery) & "\",\"scope\":\"" & my escapeJSON(searchScope) & "\",\"count\":" & matchedCount & ",\"limit\":" & resultLimit & ",\"tasks\":[" & my joinText(jsonItems, ",") & "]}"
end searchTasksToJSON

on shouldIncludeTaskForSearch(taskItem, searchScope)
	if searchScope is "all" then return true
	return my shouldIncludeTask(taskItem, searchScope)
end shouldIncludeTaskForSearch

on taskMatchesQuery(taskItem, searchQuery)
	set haystackText to my taskSearchText(taskItem)
	ignoring case
		if haystackText contains searchQuery then return true
	end ignoring
	return false
end taskMatchesQuery

on taskSearchText(taskItem)
	tell application "/Applications/OmniFocus.app"
		tell taskItem
			set parts to {my safeValue(id), my safeValue(name), my safeValue(note)}
			
			try
				set containingProject to «property FCPr»
				if containingProject is not missing value then
					set end of parts to my safeValue(name of containingProject)
					try
						set containingFolder to folder of containingProject
						if containingFolder is not missing value then set end of parts to my safeValue(name of containingFolder)
					end try
				end if
			end try
			
			try
				if «property FCpt» is not missing value then set end of parts to my safeValue(name of «property FCpt»)
			end try
			
			try
				repeat with tagItem in tags
					set end of parts to my safeValue(name of tagItem)
				end repeat
			end try
		end tell
	end tell
	return my joinText(parts, " ")
end taskSearchText

on tasksToJSON(taskItems, requestedMode)
	set jsonItems to {}
	repeat with taskItem in taskItems
		if my shouldIncludeTask(taskItem, requestedMode) then set end of jsonItems to my taskToJSON(taskItem)
	end repeat
	return "[" & my joinText(jsonItems, ",") & "]"
end tasksToJSON

on projectsToJSON(projectItems)
	set jsonItems to {}
	repeat with projectItem in projectItems
		tell application "/Applications/OmniFocus.app"
			if completed of projectItem is false then set end of jsonItems to my projectToJSON(projectItem)
		end tell
	end repeat
	return "[" & my joinText(jsonItems, ",") & "]"
end projectsToJSON

on shouldIncludeTask(taskItem, requestedMode)
	tell application "/Applications/OmniFocus.app"
		tell taskItem
			if requestedMode is "completed" then return completed
			if completed then return false
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

on operationToJSON(operationName, taskItem)
	return "{\"ok\":true,\"operation\":\"" & operationName & "\",\"task\":" & my detailTaskToJSON(taskItem) & "}"
end operationToJSON

on taskToJSON(taskItem)
	tell application "/Applications/OmniFocus.app"
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
	tell application "/Applications/OmniFocus.app"
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
	tell application "/Applications/OmniFocus.app"
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

on joinText(textItems, delimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to delimiter
	set joinedText to textItems as text
	set AppleScript's text item delimiters to oldDelimiters
	return joinedText
end joinText
