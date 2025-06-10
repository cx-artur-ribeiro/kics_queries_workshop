package Cx

import data.generic.common as common_lib
import data.generic.terraform as tf_lib

CxPolicy[result] {
	resource := input.document[i].resource.aws_route_table[name]
	route_table_open_cidr(resource.route)

	result := {
		"documentId": input.document[i].id,
		"resourceType": "aws_route_table",
		"resourceName": tf_lib.get_resource_name(resource, name),
		"searchKey": sprintf("aws_route_table[%s].route", [name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("aws_route_table[%s].route restricts CIDR", [name]),
		"keyActualValue": sprintf("aws_route_table[%s].route does not restrict CIDR", [name]),
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

route_table_open_cidr(route) {
    # Check if route is an array (is_array)
    # If so loop through each entry
    # Check if entry has "vpc_peering_connection_id"
    # Call unrestricted
} else {
    # If route is a single object (is_object)
    # Check if it has "vpc_peering_connection_id"
    # Call unrestricted
}