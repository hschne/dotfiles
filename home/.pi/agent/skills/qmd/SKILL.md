---
name: wiki
description: "Manage Hans's personal knowledge base at ~/Documents/Wiki/. Use when Hans needs to save documents (specs, plans, runbooks, memory...) or to search for past decisions, architectural context, and how something was done. Covers both storage and retrieval via QMD (hybrid search engine: BM25 + vector + reranking)."
---

# Wiki Skill

The Wiki is Hans's personal knowledge base at `~/Documents/Wiki/`, indexed and searchable via QMD (hybrid search engine with BM25 + vector + reranking).

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

## Storing Documents

### Where to Save What

| User says | Location | File naming |
|-----------|----------|------------|
| "Save a spec" | `projects/<project>/specs/<name>.md` | `<slug>.md` |
| "Create a resource/runbook" | `resources/<name>.md` | `<slug>.md` |
| "Write a project plan" | `projects/<project>/plans/<name>.md` | `26-03-05-<slug>.md` |
| "Save to the project" | `projects/<project>/<name>.md` | varies |
| "Create a document" | `resources/<name>.md` | `<slug>.md` |
| "Add to an area" | `areas/<area>/<name>.md` | `<slug>.md` |
| "Save a decision doc" | `resources/` or `projects/<project>/` | `<slug>.md` |

**File naming conventions:**
- Resources & specs: lowercase, hyphens (`glacier-backup-recovery.md`)
- Plans: date prefix `YY-MM-DD-<slug>.md` (e.g., `26-03-05-phase-list-redesign.md`)

### Example storage workflows

**Save a runbook:**
```bash
# User: "Save this as a runbook"
# Action: Write to resources/<descriptive-slug>.md
# Then: qmd update
```

**Create a project spec:**
```bash
# User: "Save this database schema spec"
# Action: Write to projects/<project>/specs/<name>.md
# Then: qmd update
```

**Write a project plan:**
```bash
# User: "Write a plan for the settings redesign"
# Action: Use /plan command, writes to projects/<project>/plans/
# Then: plan complete (when user explicitly asks)
```

**Update index after storing:**
```bash
qmd update          # Re-index changed files (fast)
qmd embed           # Regenerate vectors (slow, needed for vsearch/query on new files)
```

## Retrieving Documents 

Use QMD proactive when:

- You need architectural context before making a decision
- The user asks about past work or decisions
- You're about to do something that might duplicate prior research

## Search Commands

```bash
# Fast keyword search — use for specific terms, names, file types
qmd search "query" -n 5

# Search across specific collections only
qmd search "query" -c projects -c resources

# Best quality — hybrid + reranking. Slow, but highest accuracy 
qmd query "query" -n 5

# Semantic search — use when meaning matters more than keywords
qmd vsearch "query" -n 5

# Retrieve full document by path
qmd get "projects/mapit/plans/26-02-19-phase-settings.md" --full

# Get multiple files by glob
qmd multi-get "projects/mapit/plans/*.md"
```

## Output formats

```bash
--json     # Structured output for parsing
--files    # Just paths and scores, for loading files
--full     # Include full document content in results
--md       # Markdown-formatted output
```

### Workflow Patterns 

Prefer search, but fall back to `query` if no results are found.

#### Starting a project session

```bash
# 1. Get project summary if it exists
qmd get "projects/mapit/summary.md" --full 2>/dev/null

# 2. Search for recent context
qmd search "mapit" -c projects -n 5
```

To load existing plans for a project, see the `plan` skill.

#### Document retrieval

In any context, Hans may ask you to look into previous sessions or prior research. 

```bash
# Try keyword first (fast)
qmd search "ZUGFeRD PDF generation" -n 5
# Use hybrid if no proper results
qmd query "invoice generation compliance" -n 5

# Use specific collections if known
qmd search "Redis caching" -c projects -c resources
qmd query "Redis caching" -c projects -c resources
```

#### Searching archive (explicit only)

```bash
qmd query "old-project-name" -c archive -n 5
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
