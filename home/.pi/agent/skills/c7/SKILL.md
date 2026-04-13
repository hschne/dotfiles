---
name: c7
description: Fetch up-to-date library documentation. Use when the user asks to look up docs, documentation, check API usage, or tells you to use context7.
---

# Context7 Skill

Use the `c7` CLI to fetch current library documentation from Context7.

## Quick lookup

The `get` command resolves a library name and fetches docs in one step:

```bash
c7 get <library-name> "<query>"
```

Examples:

```bash
c7 get rails "active record scopes"
c7 get next.js "middleware routing"
c7 get tailwindcss "responsive grid"
c7 get kamal "deploy with secrets" --tokens 8000
```

Use `--tokens N` to control how much documentation is returned (default 5000).

## Search for a library

When you need the exact library ID first:

```bash
c7 search <library-name>
```

## Fetch docs by known ID

When the library ID is already known (e.g. from a previous search):

```bash
c7 docs <library-id> "<query>"
c7 docs /rails/rails "validations" --tokens 8000 --topic models
```

Flags: `--tokens N`, `--page N` (1–10), `--topic TOPIC`.

## Guidelines

- Prefer `get` for one-shot lookups — it caches resolved IDs automatically.
- Use `search` when the user wants to browse or compare libraries.
- Use `docs` when a library ID is already known from prior context.
- Pipe output or read it directly — it's plain text / markdown, ready to use.
- Run `c7 cache clear` if results seem stale.
