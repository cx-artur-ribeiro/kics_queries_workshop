# KICS Hands-on Workshop

This repository contains materials and exercises for the KICS Queries Workshop.

You'll learn how to:
- Understand how KICS uses REGO queries to find vulnerabilities in IaC files;
- Analyze KICS payloads;
- Write and improve REGO queries for KICS using real examples;
- Debug and test queries effectively;
- Apply best practices to avoid false positives and other regression problems.

## Prerequisites

- Clone the [KICS](https://github.com/Checkmarx/kics) repository locally
- Install Go (>= 1.23 recommended)
- (Optional) Familiarity with REGO language and OPA concepts
- (Optional) Access to [REGO Playground](https://play.openpolicyagent.org/)

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
