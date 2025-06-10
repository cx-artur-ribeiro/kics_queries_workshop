# KICS Hands-on Workshop

This repository contains materials and exercises for the KICS Queries Workshop.

You'll learn how to:
- Understand how KICS uses REGO queries to find vulnerabilities in IaC files;
- Analyze KICS payloads;
- Write and improve REGO queries for KICS using real examples;
- Debug and test queries effectively;
- Apply best practices to avoid false positives and other regression problems.

## Prerequisites

- Clone the [KICS](https://github.com/Checkmarx/kics) repository locally;
- Access to [REGO Playground](https://play.openpolicyagent.org/)
- (Optional) Install Go (>= 1.23 recommended) - to run kics locally or use docker;
- (Optional) Familiarity with REGO language and OPA concepts;

## Running KICS Locally

Example command to run a scan with payload dump:

```bash
go run cmd/console/main.go scan \
  -p "path/to/test_file.yaml" \
  -o "results" \
  --output-name "workshop_results_example.json" \
  -i "unique-id" \
  -d "payload_output.json" \
  -v
```

## Useful Links

- REGO Language Documentation - https://www.openpolicyagent.org/docs/policy-language      
- KICS Official Documentation - https://docs.kics.io/latest/   
- KICS GITHUB Repo - https://github.com/Checkmarx/kics   
- OPA REGO Playground - https://play.openpolicyagent.org/