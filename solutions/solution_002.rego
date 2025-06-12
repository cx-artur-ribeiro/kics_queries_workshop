package Cx

CxPolicy[result] {
	resource := input.document[i].resource.aws_route_table[name]
	route_table_open_cidr(resource.route)

	result := {
		"documentId": input.document[i].id,
		"resourceType": "aws_route",
		"resourceName": get_resource_name(resource, name),
		"searchKey": sprintf("aws_route_table[%s].route", [name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("aws_route_table[%s].route restricts CIDR", [name]),
		"keyActualValue": sprintf("aws_route_table[%s].route does not restrict CIDR", [name]),
		"searchLine": build_search_line(["resource", "aws_route_table", name, "route"], []),
	}
}

openCidrs := {"cidr_block": "0.0.0.0/0", "ipv6_cidr_block": "::/0", "destination_cidr_block": "0.0.0.0/0", "destination_ipv6_cidr_block": "::/0"}

unrestricted(route) {
	is_array(route)
	route[r][x] == openCidrs[x]
} else {
	is_object(route)
	route[x] == openCidrs[x]
}

# SOLUTION_002
route_table_open_cidr(route) {
	is_array(route)
	entry := route[i]
	valid_key(entry, "vpc_peering_connection_id")
	unrestricted(entry)
} else {
    is_object(route)
	valid_key(route, "vpc_peering_connection_id")
	unrestricted(route)
}

valid_key(obj, key) {
	_ = obj[key]
	not is_null(obj[key])
} else = false {
	true
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
