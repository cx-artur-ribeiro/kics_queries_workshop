## Exercise 1 — Extending an Existing Query
### Description
In this exercise, you will improve an existing KICS query by addressing a false positive (FP).
The provided query checks whether defined `aws_security_group` resources are used within a Terraform project. It uses the built-in `walk` function to iterate through the document and a helper function `is_used` with several patterns to detect usage.
However, this query currently misses one case: `aws_security_group` resources used by `aws_elasticache_instance` resources. As a result, it produces a false positive if a security group is used in this way.

### Your Task
👉 Your goal is to add a new case to the existing `is_used` function to support this missing case (analyze the payloads provided, as well as the positive and negative tests).

👉 Specifically, you need to add a new clause to `is_used` that matches the usage of `aws_security_group` in the `security_group_ids` field of `aws_elasticache_instance`.

👉 Once added, this will eliminate the false positive.

### Provided Files
- query.rego — the query source code;
- metadata.json — query metadata;
- Positive test and the respective payload;
- Negative test and the respective payload;

### Steps
- Carefully read the provided query.rego;
- Understand how the is_used function works — note the multiple patterns are already present;
- Analyze the payloads provided;
- Copy any required auxiliary functions from kics internal libraries (you can find them in the KICS repo under assets/libraries);
- Prepare Rego Playground environment and verify that everything is ready to run.
- Add a new is_used clause to handle aws_elasticache_instance usage;
- Run the provided tests to verify that:
  - The false positive is eliminated (negative test now passes);
  - The positive test still passes.
