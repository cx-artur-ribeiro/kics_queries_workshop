package Cx

pl := {"aws_s3_bucket_policy", "aws_s3_bucket"}

CxPolicy[result] {
	resourceType := pl[r]
	resource := input.document[i].resource[resourceType][name]

	allows_action_from_all_principals(resource.policy, "delete")

	result := {
		"documentId": input.document[i].id,
		"resourceType": resourceType,
		"resourceName": get_specific_resource_name(resource, "aws_s3_bucket", name),
		"searchKey": sprintf("%s[%s].policy", [resourceType, name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("%s[%s].policy.Action should not be a 'Delete' action", [resourceType, name]),
		"keyActualValue": sprintf("%s[%s].policy.Action is a 'Delete' action", [resourceType, name]),
		"searchLine": build_search_line(["resource", resourceType, name, "policy"], []),
	}
}

CxPolicy[result] {
	resourceType := pl[r]
	resource := input.document[i].resource[resourceType][name]

	allows_all_s3_actions_from_all_principals_match(resource.policy)

	result := {
		"documentId": input.document[i].id,
		"resourceType": resourceType,
		"resourceName": get_specific_resource_name(resource, "aws_s3_bucket", name),
		"searchKey": sprintf("%s[%s].policy", [resourceType, name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("%s[%s].policy.Action should not be a 'Delete' action", [resourceType, name]),
		"keyActualValue": sprintf("%s[%s].policy.Action is a 'Delete' action", [resourceType, name]),
		"searchLine": build_search_line(["resource", resourceType, name, "policy"], []),
	}
}

######### Common and Terraform Library Functions #########
anyPrincipal(statement) {
    some p
    p = get_principal(statement)
	contains(p, "*")
}

anyPrincipal(statement) {
    some p
    p = get_principal(statement)
	contains(p[_], "*")
}

anyPrincipal(statement) {
	some p
	p = get_principal_aws(statement)
	is_string(p)
	contains(p, "*")
}

anyPrincipal(statement) {
    some arr
    arr = get_principal_aws(statement)
    is_array(arr)
    some i
    contains(arr[i], "*")
}

get_principal(statement) = p {
	# Check if the statement has a "Principal" field. -> payload_positive4, line 33, "Principal":{"AWS":"*"}
    # If it does, return it directly.
} else = p {
	# If "Principal" is not found, check if it uses the alternative "Principals" field. -> payload_positive1, line 35, "Principals":{"AWS":["*"]}
    # Return that instead.
}

get_principal_aws(statement) = p {
    # First, use get_principal to fetch the principal block.
    # Then, check if the AWS field exists within it.
	some principal
	principal = get_principal()
	# Then, check if the AWS field exists within it.

	# Return the AWS-specific principal(s)

}

allows_action_from_all_principals(json_policy, action) {
 	policy := json_unmarshal(json_policy)
	st := get_statement(policy)
	statement := st[_]
	statement.Effect == "Allow"
    anyPrincipal(statement)
    containsOrInArrayContains(get_action(statement), action)
}

allows_all_s3_actions_from_all_principals_match(json_policy) {
    policy := json_unmarshal(json_policy)
	st := get_statement(policy)
	statement := st[_]
	statement.Effect == "Allow"
	anyPrincipal(statement)
	action_matches_s3_star(get_action(statement))
}

get_action(statement) = a {
  # Check if the statement uses the "Action" field -> payload_positive4, line 33, {"Statement":[{"Action":["*"]

  # if so, assign the value to a

} else = a {
  # If "Action" is not present, check for the plural "Actions" -> payload_positive1, line 35, {"Statement":[{"Actions":["s3:Delete*"]

  # if so, assign the value to a

}

action_matches_s3_star(action_value) {
    # Check if the action is a string
    # call the auxiliar function action_is_s3_star_or_star
}

action_matches_s3_star(action_value) {
    # Check if the action is an array

	# then call the auxiliar function action_is_s3_star_or_star on each value of the array
	some i

}

action_is_s3_star_or_star(action) {
	action == "*"
} else {
	action == "s3:*"
}






############### Auxiliar Library Functions ###############
# Check if field contains value or if any element from field contains value
containsOrInArrayContains(field, value) {
	is_string(value)
	contains(lower(field), value)
}

containsOrInArrayContains(field, value) {
	is_array(field)
	some i
	contains(lower(field[i]), value)
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

get_resource_name(resource, resourceDefinitionName) = name {
	name := resource["name"]
} else = name {
	name := resource["display_name"]
}  else = name {
	name := resource.metadata.name
} else = name {
	prefix := resource.name_prefix
	name := sprintf("%s<unknown-sufix>", [prefix])
} else = name {
	name := get_tag_name_if_exists(resource)
} else = name {
	name := resourceDefinitionName
}

get_specific_resource_name(resource, resourceType, resourceDefinitionName) = name {
	field := resourceFieldName[resourceType]
	name := resource[field]
} else = name {
	name := get_resource_name(resource, resourceDefinitionName)
}

get_module_equivalent_key(provider, moduleName, resource, key) = keyInResource {
	providers := data.common_lib.modules[provider]
	module := providers[moduleName]
	inArray(module.resources, resource)
	keyInResource := module.inputs[key]
}

get_statement(policy) = st {
	is_object(policy.Statement)
	st = [policy.Statement]
} else = st {
	is_array(policy.Statement)
	st = policy.Statement
}

json_unmarshal(s) = result {
	s == null
	result := json.unmarshal("{}")
}

json_unmarshal(s) = result {
	s != null
	result := json.unmarshal(s)
}

get_tag_name_if_exists(resource) = name {
	name := resource.tags.Name
} else = name {
	tag := resource.Properties.Tags[_]
	tag.Key == "Name"
	name := tag.Value
} else = name {
	tag := resource.Properties.FileSystemTags[_]
	tag.Key == "Name"
	name := tag.Value
} else = name {
	tag := resource.Properties.Tags[key]
	key == "Name"
	name := tag
} else = name {
	tag := resource.spec.forProvider.tags[_]
	tag.key == "Name"
	name := tag.value
} else = name {
	tag := resource.properties.tags[key]
	key == "Name"
	name := tag
}

# Checks if a list contains an item
inArray(list, item) {
	some i
	list[i] == item
}

resourceFieldName = {
	"google_bigquery_dataset": "friendly_name",
	"alicloud_actiontrail_trail": "trail_name",
	"alicloud_ros_stack": "stack_name",
	"alicloud_oss_bucket": "bucket",
	"aws_s3_bucket": "bucket",
	"aws_msk_cluster": "cluster_name",
	"aws_mq_broker": "broker_name",
	"aws_elasticache_cluster": "cluster_id",
}