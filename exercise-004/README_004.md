## Exercise 4 — Fix Library Functions for KICS policies
### Description
In this exercise, you'll improve helper functions used to identify overly permissive AWS IAM policy statements and use those improved functions on KICS policies.
The primary goal is to refactor and consolidate the existing logic in the policy and helper functions to be more reusable and accurate, and then apply that logic in the creation of new checks targeting unsafe "s3:*" or "*" actions allowed to "*" principals.

Your Task
👉 Implement some helper functions to use common logic for extracting principals/principal and actions/action, as well as detecting `s3:*` or `*` actions which are granted to "*" principals.

### Provided Files
- query.rego — includes the existing base logic, helper functions, and room to add new policies already ready for Rego Playground;
- metadata.json — query metadata;
- Positive tests and the respective payloads;
- Negative test and the respective payload;

### Steps
- Implement `get_principal` and `get_principal_aws` functions to fetch both cases of each field (Principal/Principals, Action/Actions);
- Implement `get_action`, `action_matches_s3_star` to detect `s3:*` or `*` actions;
- Test these improvements on the last Policy for directly defined resources (examples on the folder test);
- This policy should flag any case where `s3:*` or `*` actions are granted to "*" principals (positive1/2/3 files in the folder test have vulnerabilities on the lines 37).
- Evaluate the vulnerability on line 37 and compare with each KICS payload. The payload's field that describes the vulnerability are the fields on the lines 35 of each payload_positive1/2/3.

#### First part:
Complete the functions get_principal and get_principal_aws by analyzing the different payloads provided.
Check line 35 of the positive payloads and the corresponding vulnerability on the test file, line 37.

```
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
```

#### Second part:
Complete the functions get_action and action_matches_s3_star.
Check line 35 of the positive payloads and the corresponding vulnerability on the test file, line 37.

```
#Checks if an action is allowed for all principals
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
```

### Test on REGO Playground to see if you get the expected results
