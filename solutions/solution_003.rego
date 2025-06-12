package Cx

publicOptions := {"Container", "Blob"}

CxPolicy[result] {
	doc := input.document[i]
	[path, value] = walk(doc)

	value.type == "Microsoft.Storage/storageAccounts/blobServices/containers"

	[val, val_type] := getDefaultValueFromParametersIfPresent(doc, value.properties.publicAccess)
	val == publicOptions[o]

	result := {
		"documentId": input.document[i].id,
		"resourceType": value.type,
		"resourceName": value.name,
		"searchKey": sprintf("%s.name=%s.properties.publicAccess", [concat_path(path), value.name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("resource with type 'Microsoft.Storage/storageAccounts/blobServices/containers' shouldn't have 'publicAccess' %s set to 'Container' or 'Blob'", [val_type]),
		"keyActualValue": sprintf("resource with type 'Microsoft.Storage/storageAccounts/blobServices/containers' has 'publicAccess' property set to '%s'", [publicOptions[o]]),
		"searchLine": build_search_line(path, ["properties", "publicAccess"]),
	}
}

CxPolicy[result] {
	doc := input.document[i]
	[path, value] = walk(doc)

	value.type == "Microsoft.Storage/storageAccounts/blobServices"

	[childPath, childValue] := walk(value.resources)

	childValue.type == "containers"
	[val, val_type] := getDefaultValueFromParametersIfPresent(doc, childValue.properties.publicAccess)
	val == publicOptions[o]

	result := {
		"documentId": input.document[i].id,
		"resourceType": value.type,
		"resourceName": value.name,
		"searchKey": sprintf("%s.name=%s.resources.name=%s.properties.publicAccess", [concat_path(path), value.name, childValue.name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("resource with type 'containers' shouldn't have 'publicAccess' %s set to 'Container' or 'Blob'",[val_type]),
		"keyActualValue": sprintf("resource with type 'containers' has 'publicAccess' property set to '%s'", [publicOptions[o]]),
		"searchLine": build_search_line(childPath, ["properties", "publicAccess"]),
	}
}

CxPolicy[result] {
	doc := input.document[i]
	[path, value] = walk(doc)

	value.type == "Microsoft.Storage/storageAccounts"

	[childPath, childValue] := walk(value.resources)

	childValue.type == "blobServices/containers"
	[val, val_type] := getDefaultValueFromParametersIfPresent(doc, childValue.properties.publicAccess)
	val == publicOptions[o]

	result := {
		"documentId": input.document[i].id,
		"resourceType": value.type,
		"resourceName": value.name,
        "searchKey": sprintf("%s.name=%s.resources.name=%s.properties.publicAccess", [concat_path(path), value.name, childValue.name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("resource with type 'blobServices/containers' shouldn't have 'publicAccess' %s set to 'Container' or 'Blob'", [val_type]),
		"keyActualValue": sprintf("resource with type 'blobServices/containers' has 'publicAccess' property set to '%s'", [publicOptions[o]]),
		"searchLine": build_search_line(childPath, ["properties", "publicAccess"]),
	}
}

# SOLUTION_003
CxPolicy[result] {
	doc := input.document[i]

	[path, value] = walk(doc)
	value.type == "Microsoft.Storage/storageAccounts"

	[childPath, childValue] := walk(value.resources)
	childValue.type == "blobServices"

	[subchildPath, subchildValue] := walk(childValue.resources)
	subchildValue.type == "containers"

	[val, val_type] := getDefaultValueFromParametersIfPresent(doc, subchildValue.properties.publicAccess)
	val == publicOptions[o]

	result := {
		"documentId": input.document[i].id,
		"resourceType": value.type,
		"resourceName": value.name,
        "searchKey": sprintf("%s.name=%s.resources.name=%s.resources.name=%s.properties.publicAccess", [concat_path(path), value.name, childValue.name, subchildValue.name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("resource with type 'containers' shouldn't have 'publicAccess' %s set to 'Container' or 'Blob'", [val_type]),
		"keyActualValue": sprintf("resource with type 'containers' has 'publicAccess' property set to '%s'", [publicOptions[o]]),
		"searchLine": build_search_line(path, ["resources", childPath[0], "resources", subchildPath[0], "properties", "publicAccess"]),
	}
}

build_search_line(path, obj) = resolvedPath {
	resolveArray := [x | pathItem := path[n]; x := convert_path_item(pathItem)]
	resolvedObj := [x | objItem := obj[n]; x := convert_path_item(objItem)]
	resolvedPath = array.concat(resolveArray, resolvedObj)
}

convert_path_item(pathItem) = convertedPath {
	is_number(pathItem)
	convertedPath := sprintf("%d", [pathItem])
} else = convertedPath {
	convertedPath := sprintf("%s", [pathItem])
}

concat_path(path) = concatenated {
	concatenated := concat(".", [x | x := resolve_path(path[_]); x != ""])
}

resolve_path(pathItem) = resolved {
	contains(pathItem, ".")
	resolved := sprintf("{{%s}}", [pathItem])
} else = resolved {
    contains(pathItem, "=")
    resolved := sprintf("{{%s}}", [pathItem])
} else = resolved {
    contains(pathItem, "/")
    resolved := sprintf("{{%s}}", [pathItem])
} else = resolved {
	is_number(pathItem)
	resolved := ""
} else = pathItem

getDefaultValueFromParametersIfPresent(doc, valueToCheck) = [value, propertyType] {
	parameterName := isParameterReference(valueToCheck)
	parameter := doc.parameters[parameterName].defaultValue
	value := parameter
	propertyType := "parameter default value"
} else = [value, propertyType] {
	not isParameterReference(valueToCheck)
	value := valueToCheck
	propertyType := "property value"
}

isParameterReference(valueToCheck) = parameterName {
	startswith(valueToCheck, "[parameters('")
	endswith(valueToCheck, "')]")
	parameterName := trim_right(trim_left(trim_left(valueToCheck, "[parameters"), "('"), "')]")
}