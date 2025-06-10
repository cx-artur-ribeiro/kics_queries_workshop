## Exercise 2 — Fixing a False Positive and Improving the Result Format
### Description
In this exercise, you will complete and improve a KICS query that detects insecure routes in AWS route tables. The goal is to identify routes that expose traffic to the public internet via an open CIDR (e.g., 0.0.0.0/0) and are connected using a `vpc_peering_connection_id`.
However, the query has two problems:
- The helper function `route_table_open_cidr()` is scaffolded but not yet implemented;
- The `searchLine` is missing from the query result, making it hard for users to locate the exact line of the issue in the source file.

Your Task
👉 Implement the `route_table_open_cidr()` helper function to check each route individually, and only return true when:
- the route has a `vpc_peering_connection_id`, and
- the CIDR used is one of the known open CIDRs (0.0.0.0/0, ::/0, etc).

👉 The helper must handle both:
- arrays of route objects;
- a single route object.

👉 Add a searchLine
- Add a proper `searchLine` to the query result using the KICS library (build_search_line(...)).
- This will help users quickly locate the misconfiguration in their code.

### Provided Files
- query.rego — the source code of the KICS query;
- metadata.json — query metadata;
- Positive test and the respective payload — should be flagged line 9;
- Negative TEST and the respective payload — should not be flagged (currently flagged due to FP).

### Steps
- Carefully read the current query.rego, especially the stubbed route_table_open_cidr() function.
- Copy any required auxiliary functions from kics internal libraries (you can find them in the KICS repo under assets/libraries);
- First, implement the logic inside route_table_open_cidr() so that:
  - It correctly handles both arrays of routes and single route objects;
  - It returns true only when a route contains both:
    - a vpc_peering_connection_id;
    - an open CIDR (e.g., 0.0.0.0/0, ::/0, etc).
- Run the tests and confirm that:
  - The positive test is flagged;
  - The negative test is not flagged;
  - The result does not yet contain a searchLine;
- Next, add the searchLine to the result object using KICS helpers (e.g., build_search_line(...)):
- Run the tests again and verify that:
  - The query now includes a correct searchLine (should point to line 9 in the positive test);
  - The positive test is flagged;
  - The negative test is not flagged;
  - The searchLine accurately points to the insecure route.