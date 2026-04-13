# Wiki Retrieval

Use this reference when searching or fetching wiki content with QMD.

## Retrieval Strategy

1. Start with `qmd search` for fast keyword retrieval.
2. Narrow with `-c <collection>` when you know the likely location.
3. Use `qmd query` when keyword search is weak or ranking quality matters more.
4. Use `qmd vsearch` when semantic similarity matters more than exact terms.
5. Use `qmd get` or `qmd multi-get` once you know the path.
6. Search `archive` only when historical or inactive material is needed.

## Commands

```bash
qmd search "query" -n 5
qmd search "query" -c projects -c resources
qmd query "query" -n 5
qmd vsearch "query" -n 5
qmd get "projects/mapit/plans/26-02-19-phase-settings.md" --full
qmd multi-get "projects/mapit/plans/*.md"
```

## Output Options

```bash
--json     # Structured output
--files    # Paths and scores only
--full     # Full document content
--md       # Markdown output
```

## Session Patterns

### Start a project session

```bash
qmd get "projects/<project>/summary.md" --full 2>/dev/null
qmd search "<project>" -c projects -n 5
```

### Retrieve prior work

```bash
qmd search "ZUGFeRD PDF generation" -n 5
qmd query "invoice generation compliance" -n 5
qmd search "Redis caching" -c projects -c resources
qmd query "Redis caching" -c projects -c resources
```

### Search archive explicitly

```bash
qmd query "old-project-name" -c archive -n 5
```

## Heuristics

- Prefer the narrowest useful collection scope.
- Use `summary.md` files first for orientation when present.
- If results are weak, refine the query before broadening the scope.
- `qmd query` may have a slower first run because it loads models.
- Read the result context strings to understand why a document matched.

## Score Guide

| Score    | Meaning                     |
| -------- | --------------------------- |
| `> 80%`  | highly relevant             |
| `50-80%` | probably relevant           |
| `< 50%`  | weak match, verify manually |
