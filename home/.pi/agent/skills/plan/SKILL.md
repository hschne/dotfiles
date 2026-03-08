---
name: plan
description: "Understand how plans are written, named, stored, and saved. Use when writing a plan, looking up existing plans, or working on a feature that might have one."
---

# Plan Skill

Plans are feature planning documents. They live in two places:

- **Draft**: `plans/` in the project repo (editable with vim, gitignore-able)
- **Final**: `~/Documents/Wiki/projects/<project>/plans/` (indexed by QMD)

Use `/plan` to create a new draft. Use `plan complete` to move a finished draft to the Wiki — **only when the user explicitly asks you to**.

## File Naming

All plan files use `YY-MM-DD-<slug>.md` — two-digit year, lowercase-hyphenated slug.

Examples:

- `26-03-05-phase-list-redesign.md`
- `26-02-19-phase-settings.md`

## Loading Existing Plans

Search for related decisions:

```bash
qmd search "<relevant keywords>" -c projects -n 5
```

## Plan Structure

```markdown
# <Title>

## Goal

<What this achieves and why — 2-3 sentences max>

## Current State

<How things work today — relevant code, data model, UI. Be specific with file paths and code.>

## New Behavior

<What changes — describe the user-visible result. Include mockups/layouts as ASCII if helpful.>

## Decisions

<Key design decisions as Q&A pairs. State the question, the decision, and the rationale.
Focus on the WHY — these are the most valuable part of the plan.>

## Implementation Plan

<Numbered steps with file paths and code snippets. Each step should be small enough to
implement and verify independently. Include model changes, controller changes, frontend
changes, and tests.>

## What We're NOT Doing

<Explicitly scope out things that might seem related but are deferred or out of scope.>

## Risks & Edge Cases

<Things that could go wrong or need special handling.>

## Follow-Ups

<Things to do after this plan is implemented — improvements, related features, known gaps to revisit.>
```

Skip sections that don't apply. The **Decisions** section is the most valuable — always include it.

## Lifecycle

1. `/plan <topic>` — research, ask clarifying questions, write draft to `plans/YY-MM-DD-<slug>.md`
2. Edit with vim until satisfied
3. `plan complete` — moves the file to `~/Documents/Wiki/projects/<project>/plans/` and runs `qmd update`

## The `plan` Command

```
plan list [--format json]              # list draft plans in plans/
plan projects [--format json]          # list available Wiki projects
plan complete [<plan-file>]            # finalize and move a draft to the Wiki
  --project <name>                     # override project auto-detection
  --no-interactive                     # disable FZF; error if selection is ambiguous
```

### Agent usage rules

- **Never call `plan complete` unless the user explicitly asks.** Writing a plan does not imply saving it.
- Use `--no-interactive` when running non-interactively.
- Use `--format json` with `plan list` and `plan projects` for structured output.
- If the project cannot be auto-detected, use `plan projects --format json` to get the list, then pass `--project <name>`.

### Examples

```bash
# List available draft plans
plan list
plan list --format json

# List available Wiki projects
plan projects
plan projects --format json

# Complete a plan (auto-detect plan and project)
plan complete

# Complete a specific plan for a specific project, non-interactively
plan complete 26-03-07-my-feature.md --project myproject --no-interactive
```
