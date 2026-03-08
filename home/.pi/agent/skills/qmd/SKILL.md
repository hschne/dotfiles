---
name: qmd
description: "Search Hans's personal knowledge base using QMD. Use when working on any project, looking up past decisions, finding plans, recalling how something was done, or when context from previous sessions would be useful."
---

# QMD Skill

QMD is a local hybrid search engine (BM25 + vector + reranking) indexing Hans's entire
knowledge base at `~/Documents/Wiki/`.

## When to use

Use QMD proactive **during a session** when:

- You need architectural context before making a decision
- The user asks about past work or decisions
- You're about to do something that might duplicate prior research

## Knowledge Base Structure

```
~/Documents/Wiki/
  projects/          # Active projects, each with plans/ and log/
  areas/             # Ongoing responsibilities
  resources/         # Reusable reference knowledge
  memory/            # AI workflow artifacts
    agents/          # Reusable AGENTS.md fragments
    sessions/        # /summary output from pi sessions
  archive/           # Inactive — old projects, inactive responsibilities...
```

## Collections

| Name      | Contains                           | Default search |
| --------- | ---------------------------------- | -------------- |
| projects  | All active project files           | ✓              |
| areas     | Ruby community, writing, life      | ✓              |
| resources | Research, runbooks, lists          | ✓              |
| memory    | Agent fragments, session summaries | ✓              |
| archive   | Old/inactive material              | explicit only  |

## Search Commands

```bash
# Fast keyword search — use for specific terms, names, file types
qmd search "query" -n 5

# Restrict to one collection
qmd search "query" -c projects -n 5
qmd search "query" -c resources -n 5

# Semantic search — use when meaning matters more than keywords
qmd vsearch "query" -n 5

# Best quality — hybrid + reranking (slower, use when accuracy matters)
qmd query "query" -n 5

# Retrieve full document by path
qmd get "projects/mapit/plans/26-02-19-phase-settings.md" --full

# Get multiple files by glob
qmd multi-get "projects/mapit/plans/*.md"

# Search across specific collections only
qmd search "query" -c projects -c resources
```

## Output formats

```bash
--json     # Structured output for parsing
--files    # Just paths and scores, for loading files
--full     # Include full document content in results
--md       # Markdown-formatted output
```

## Workflow patterns

### Starting a project session

```bash
# 1. Get project summary if it exists
qmd get "projects/mapit/summary.md" --full 2>/dev/null

# 2. Search for recent context
qmd search "mapit" -c projects -n 5
```

To load existing plans for a project, see the `plan` skill.

### Looking up a past decision or research

```bash
# Try keyword first (fast)
qmd search "ZUGFeRD PDF generation" -n 5

# If weak results, try semantic
qmd vsearch "how to generate compliant invoices in Rails" -n 5
```

### Finding reusable AGENTS.md fragments

```bash
qmd search "svelte conventions" -c memory
qmd search "Rails style guide" -c memory
qmd multi-get "memory/agents/*.md"
```

### Searching archive (explicit only)

```bash
qmd search "query" -c archive -n 5
```

## Updating the index

After adding or editing files:

```bash
qmd update          # Re-index changed files (fast)
qmd embed           # Regenerate vectors (slow, needed for vsearch/query)
```

## Score interpretation

| Score  | Meaning            |
| ------ | ------------------ |
| > 80%  | Highly relevant    |
| 50-80% | Probably relevant  |
| < 50%  | Weak match, verify |

## Tips

- `summary.md` files in folders give quick orientation — fetch these first
- Always try `qmd search` first — it's instant (BM25, no model needed)
- Use `-c projects` or `-c resources` to narrow scope when you know where to look
- `qmd query` loads LLM models on first run — takes ~10s on CPU, fast after
- The context strings in results tell you _why_ a document was retrieved — read them
