## Exercise 3 — Add a New Policy to the Query
### Description
In this exercise, you will write a new KICS policy to detect when Azure Storage container resources have the `publicAccess` property set to "Container" or "Blob". The new policy specifically targets a deeper nested resource structure:
- The top-level resource is of type `Microsoft.Storage/storageAccounts`;
- It contains nested resources of type `blobServices`;
- Which themselves contain nested resources of type `containers`;
The policy must check that none of these containers resources have publicAccess set to "Container" or "Blob".

Your Task
👉 Write a new KICS policy rule that:
- Walks through the nested resource structure (storageAccounts → blobServices → containers);
- Checks the `publicAccess` property in each container;
- Flags the resource if the value is "Container" or "Blob";
- Returns detailed information including a correctly constructed searchKey and a precise searchLine using the KICS helper build_search_line.

### Provided Files
- query.rego — the base policy code that includes existing related rules, plus helper functions and imports you can reuse;
- metadata.json — query metadata;
- Positive test and the respective payload — should be flagged line 59;

### Steps
- Read the provided query.rego code carefully, especially the existing policy rules that check `publicAccess` in other nested resource scenarios;
- Use the provided sample ARM template (payload.json) to understand the resource nesting structure and the property paths;
- Implement the new policy rule to:
  - Traverse the nested resources inside a `Microsoft.Storage/storageAccounts` resource to find `blobServices`.
  - Inside `blobServices`, walk its resources to find containers.
  - Check if containers's `publicAccess` property equals "Container" or "Blob".
- Construct the result object similar to the existing rules, including:
  - documentId, resourceType, resourceName;
  - searchKey showing the path to the publicAccess property;
  - issueType set to "IncorrectValue";
  - keyExpectedValue and keyActualValue describing the issue;
  - searchLine generated with common_lib.build_search_line() correctly referencing the nested resource path.
- Run the tests again and verify that:
    - The positive test is flagged in the correct line;
    - The result is accurate and informative to the customer.
- P.S - Use the function below on rego playground so you don't face any deprecated keyword issues:
```
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
```