# Wiki Storage

Use this reference when writing or updating files in the wiki.

## Naming Rules

- Use lowercase file names with hyphens.
- Use descriptive slugs like `glacier-backup-recovery.md`.
- For project plans, use `YY-MM-DD-<slug>.md`.

## Workflow

1. Map the user's request to the correct wiki collection and subfolder.
2. Choose the final file name before writing.
3. Write or update the document.
4. Run `qmd update` after the file change.
5. Run `qmd embed` only if new content must be available to `qmd query` or `qmd vsearch` immediately.

## Examples

### Save a runbook

```bash
# Write to resources/<descriptive-slug>.md
qmd update
```

### Save a project spec

```bash
# Write to projects/<project>/specs/<slug>.md
qmd update
```

### Save a project plan

```bash
# Write to projects/<project>/plans/YY-MM-DD-<slug>.md
qmd update
```

## Index Refresh Commands

```bash
qmd update          # Re-index changed files quickly
qmd embed           # Regenerate vectors for semantic / hybrid retrieval
```

## Validation Checklist

- path matches the user's intent
- file name matches the naming convention
- file was written under `~/Documents/Wiki/`
- `qmd update` was run after changes
- `qmd embed` was run only when needed
