---
name: jq
description: Query, filter, validate, and transform JSON data with jq. Use when working with JSON files, API responses, CLI JSON output, or data pipelines that need precise extraction or reshaping.
---

# jq

Use this skill when working with JSON data, API responses, CLI output, logs, or any task that needs querying, filtering, validating, or transforming JSON with `jq`.

## Core Uses

- Query nested JSON fields
- Filter arrays and objects
- Reshape JSON output
- Merge JSON files
- Convert JSON into shell-friendly output
- Validate JSON structure quickly
- Build reliable data pipelines with CLI tools

## Essential Commands

### Basic querying

```bash
# Pretty-print JSON
jq '.' file.json

# Extract a field
jq '.fieldName' file.json

# Extract nested fields
jq '.user.email' file.json
jq '.items[0].name' file.json

# Iterate arrays
jq '.items[]' file.json

# Optional access with fallback
jq '.optionalField? // "default"' file.json
```

### Filtering and selection

```bash
# Select matching objects
jq '.items[] | select(.active == true)' file.json

# Filter by multiple conditions
jq '.users[] | select(.age > 18 and .country == "US")' users.json

# Select objects with a key
jq '.[] | select(has("email"))' file.json

# Exclude deleted items
jq '.[] | select(.status != "deleted")' file.json
```

### Object and array operations

```bash
# Get keys
jq 'keys' file.json

# Get array length
jq '.items | length' file.json

# Select fields
jq '{name, email}' file.json

# Rename fields
jq '{name: .fullName, id: .userId}' file.json

# Add a field
jq '. + {updated: true}' file.json

# Delete a field
jq 'del(.password)' file.json

# Sort and deduplicate
jq '.items | sort_by(.name) | unique' file.json
```

### String and formatting operations

```bash
# Raw string output
jq -r '.message' file.json

# String interpolation
jq -r '"Hello, \(.name)"' file.json

# Convert to CSV
jq -r '.[] | [.name, .age, .email] | @csv' file.json

# Convert to TSV
jq -r '.[] | [.name, .age, .email] | @tsv' file.json

# Compact JSON output
jq -c '.' file.json
```

### Working with multiple files

```bash
# Slurp multiple files into an array
jq -s '.' file1.json file2.json

# Merge two JSON files
jq -s '.[0] * .[1]' base.json override.json
```

### Advanced patterns

```bash
# Recursive descent for nested values
jq '.. | .email? // empty' users.json

# Sum values
jq '[.items[].price] | add' file.json

# Reduce
jq 'reduce .items[] as $item (0; . + $item.price)' file.json

# Conditional logic
jq '.items[] | if .price > 100 then "expensive" else "affordable" end' file.json

# Handle errors gracefully
jq '.items[] | try .field catch "not found"' file.json
```

## Common Patterns

### API responses

```bash
# GitHub CLI JSON output
gh pr list --json number,title,author | jq -r '.[] | "#\(.number) \(.title) by @\(.author.login)"'

# Curl + jq
curl -s https://api.example.com/data | jq '.results[] | {id, name, status}'
```

### Configuration and package files

```bash
# Read package version
jq -r '.version' package.json

# List dependencies
jq -r '.dependencies | to_entries[] | "\(.key)@\(.value)"' package.json

# Merge config files
jq -s '.[0] * .[1]' base-config.json prod-config.json
```

### Logs and reports

```bash
# Extract error messages
jq -r 'select(.level == "error") | "\(.timestamp) \(.message)"' logs.json

# Count by status
jq 'group_by(.status) | map({status: .[0].status, count: length})' items.json
```

### In-place style updates

```bash
# jq itself does not edit files in place
jq '.updated = true' file.json > file.updated.json

# With sponge from moreutils
jq '.updated = true' file.json | sponge file.json
```

## Quick Reference

### Operators

- `.field` access field
- `.[]` iterate array/object
- `|` pipe operations
- `?` optional access
- `//` default value
- `,` multiple outputs

### Useful functions

- `keys`, `values`
- `length`
- `map()`
- `select()`
- `sort`, `sort_by()`
- `group_by()`
- `unique`
- `has()`
- `type`
- `add`
- `del()`

### Useful flags

- `-r` raw output
- `-c` compact output
- `-s` slurp multiple inputs into an array
- `-R` read raw strings
- `--stream` stream large files

## Best Practices

- Start with `jq '.' file.json` to inspect structure.
- Build complex filters incrementally.
- Use `-r` when you need shell-friendly plain strings.
- Use `select()` early to reduce data volume.
- Use `?` and `//` when keys may be absent.
- Prefer writing to a new file unless in-place replacement is clearly safe.
- Confirm syntax and version behavior with `jq --version` when debugging.

## Troubleshooting

```bash
# Validate JSON
jq empty file.json

# Show top-level keys
jq 'keys' file.json

# Check type at a path
jq '.items | type' file.json

# Debug missing values
jq '.field? // "missing"' file.json

# Stream huge files
jq --stream '.' large.json
```

## Resources

- Official manual: https://jqlang.org/manual/
- Playground: https://jqplay.org/
- GitHub: https://github.com/jqlang/jq
