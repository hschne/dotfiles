---
name: yq
description: Query, filter, validate, and transform YAML data with yq. Use when working with YAML files, Kubernetes manifests, GitHub Actions workflows, Helm values, or data pipelines that need structured YAML manipulation.
---

# yq

Use this skill when working with YAML files, Kubernetes manifests, GitHub Actions workflows, Helm values, or any task that needs querying, filtering, validating, or transforming YAML with `yq`.

This skill assumes `yq` v4+ and uses Mike Farah's `yq`, which has jq-like syntax.

## Core Uses

- Query nested YAML fields
- Filter arrays and documents
- Update YAML in place
- Merge YAML files
- Work with multi-document YAML
- Convert between YAML and JSON
- Validate YAML structure quickly

## Essential Commands

### Basic querying

```bash
# Pretty-print YAML
yq '.' file.yaml

# Extract a field
yq '.fieldName' file.yaml

# Extract nested fields
yq '.spec.containers[0].name' pod.yaml
yq '.metadata.name' deployment.yaml

# Iterate arrays
yq '.items[]' file.yaml
yq '.spec.template.spec.containers[].image' deployment.yaml

# Use a default value
yq '.optional // "default"' file.yaml

# Check for field existence
yq 'has("fieldName")' file.yaml
```

### In-place updates

```bash
# Update a field
yq -i '.metadata.name = "new-name"' file.yaml

# Add a field
yq -i '.metadata.labels.app = "myapp"' file.yaml

# Delete a field
yq -i 'del(.spec.nodeSelector)' deployment.yaml

# Append to an array
yq -i '.items += [{"name": "new-item"}]' file.yaml

# Update matching elements
yq -i '(.items[] | select(.name == "foo")).status = "active"' file.yaml
```

### Filtering and selection

```bash
# Select matching documents
yq 'select(.kind == "Deployment")' k8s.yaml

# Filter array items
yq '.items[] | select(.enabled == true)' config.yaml

# Select by nested value
yq '.services[] | select(.port == 8080)' services.yaml
```

### Multi-document YAML

```bash
# Select a specific document by index
yq 'select(document_index == 0)' multi.yaml

# Process all documents
yq eval-all '.' multi.yaml

# Filter docs by kind
yq 'select(.kind == "Service")' resources.yaml

# Merge multiple YAML files
yq eval-all '. as $item ireduce ({}; . * $item)' base.yaml override.yaml

# Deep merge
yq eval-all '. as $item ireduce ({}; . *+ $item)' base.yaml override.yaml
```

### Object and array operations

```bash
# Get keys
yq 'keys' file.yaml

# Select fields
yq '{name, version}' file.yaml

# Get length
yq '.items | length' file.yaml

# Sort
yq '.items | sort_by(.name)' file.yaml

# Unique
yq '.tags | unique' file.yaml

# Delete keys
yq 'del(.metadata.annotations)' file.yaml
```

### Format conversion

```bash
# YAML to JSON
yq -o=json '.' file.yaml

# Compact JSON
yq -o=json -I=0 '.' file.yaml

# Read JSON as input
yq -p=json '.' file.json

# Pipe YAML to jq
yq -o=json '.' file.yaml | jq '.field'
```

## Common Patterns

### Kubernetes

```bash
# Read container images
yq '.spec.template.spec.containers[].image' deployment.yaml

# Set replicas
yq -i '.spec.replicas = 3' deployment.yaml

# Add label
yq -i '.metadata.labels.app = "web"' deployment.yaml

# Remove a field
yq -i 'del(.spec.template.spec.nodeSelector)' deployment.yaml
```

### GitHub Actions

```bash
# Read workflow job names
yq '.jobs | keys' .github/workflows/ci.yml

# Inspect steps
yq '.jobs.test.steps[]' .github/workflows/ci.yml

# Update action version
yq -i '(.jobs.test.steps[] | select(.uses == "actions/checkout@v3")).uses = "actions/checkout@v4"' .github/workflows/ci.yml
```

### Helm / config files

```bash
# Read values
yq '.image.tag' values.yaml

# Override a setting
yq -i '.resources.limits.memory = "512Mi"' values.yaml

# Merge base + env config
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' values.yaml values.prod.yaml
```

## Quick Reference

### Operators

- `.field` access field
- `.[]` iterate array/object
- `|` pipe operations
- `//` default value
- `*` shallow merge
- `*+` deep merge
- `,` multiple outputs

### Useful functions

- `keys`, `values`
- `length`
- `select()`
- `sort_by()`
- `group_by()`
- `unique`
- `has()`
- `type`
- `del()`
- `add`

### Useful flags

- `-i` in-place edit
- `-o` output format
- `-p` input format
- `-I` indent level
- `-r` raw output
- `-n` null input
- `-s` split multi-doc YAML

## Best Practices

- Prefer `yq '.' file.yaml` first to inspect structure before writing filters.
- Use `select()` early when narrowing large inputs.
- Use `-i` only when you're confident in the expression.
- For risky changes, write output to a temporary file first.
- Use `-o=json` when handing data off to `jq`.
- Remember that YAML anchors, tags, and formatting may not round-trip exactly.
- Confirm the installed version when syntax behaves unexpectedly: `yq --version`.

## Troubleshooting

```bash
# Validate YAML parses
yq '.' file.yaml >/dev/null

# Show type at a path
yq '.spec.template | type' file.yaml

# Inspect available keys
yq '.metadata | keys' file.yaml

# Debug missing values
yq '.field // "missing"' file.yaml
```

## Resources

- Official docs: https://mikefarah.gitbook.io/yq/
- Operators reference: https://mikefarah.gitbook.io/yq/operators/
- GitHub: https://github.com/mikefarah/yq
