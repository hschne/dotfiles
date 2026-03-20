---
name: sentry
description: "Resolve Sentry bugs using sentry-cli. Use when the user asks to investigate, triage, or fix a Sentry error, issue, or exception."
---

# Sentry Skill

Use `sentry-cli` to look up and resolve Sentry issues for the mapit project.

## Look Up an Issue

List recent issues:

```bash
sentry-cli issues list
```

Get details for a specific issue by ID:

```bash
sentry-cli issues list --issue <issue-id>
```

Show the most recent event on an issue:

```bash
sentry-cli events list --issue <issue-id>
```

Show full event detail (stack trace, context, tags):

```bash
sentry-cli events info <event-id>
```

## Workflow: Resolve a Sentry Bug

1. **Get the issue** — obtain the Sentry issue ID.

  ```bash
# Search by keyword
  sentry-cli issues list --query "is:unresolved level:error <keyword>"
# Search unresolved issues
  sentry-cli issues list --query "is:unresolved level:error"
  ```

2. **Read the events** to understand the error:

   ```bash
   sentry-cli events list --issue <issue-id>
   sentry-cli events info <event-id>
   ```

3. **Look at the stack trace** in the event output — identify the file, line, and method

4. **Read the source code** at the location indicated by the stack trace

5. **Check git history** for recent changes to that file and changes to related files in the same commit:

   ```bash
   git log --oneline -10 -- path/to/file.rb
   git show <sha>
   ```

6. **Fix the bug** following project conventions. Use applicable skills.

7. **Resolve the issue** after deploying a fix:
   ```bash
   sentry-cli issues resolve <issue-id>
   ```

## Filtering Issues

```bash
# Filter by query (same syntax as Sentry UI)
sentry-cli issues list --query "is:unresolved level:error"
sentry-cli issues list --query "is:unresolved level:error"
sentry-cli issues list --query "is:unresolved assigned:me"
```

## Marking Issues

```bash
# Resolve
sentry-cli issues resolve <issue-id>

# Ignore
sentry-cli issues ignore <issue-id>
```

## Tips

- Event output includes `tags`, `user`, `request`, `contexts` — use these to reproduce the bug
- The `release` tag matches `KAMAL_VERSION` (full git SHA) — use `git show <sha>` to see what was deployed
- Stack frames show both the minified and original source when source maps are uploaded
- For JS errors from the browser, check both `inertia` and `turbo` surface tags
