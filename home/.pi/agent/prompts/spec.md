---
description: Create a new draft spec in specs/ — research, plan, then write
---

Create a new specification for: $@

## Instructions

Follow these steps **in order**. Do NOT skip ahead to writing the spec.

### Step 1: Identify the project

Determine which project this spec belongs to from context (cwd, git remote, recent conversation, or ask me).

### Step 2: Research existing specs

Load existing specs for this project to understand conventions, architecture, and prior decisions:

```bash
qmd multi-get "projects/<project>/specs/*.md"
```

Also search for related context across the knowledge base:

```bash
qmd search "<relevant keywords>" -n 5
```

### Step 3: Understand the codebase

Before writing anything, research the current codebase to understand:

- What exists today (models, controllers, components, routes)
- How similar features were implemented
- What patterns and conventions are used
- What constraints exist (dependencies, data model, APIs)

Read relevant files. Run the app or tests if needed. Do NOT guess at implementation details.

### Step 4: Ask clarifying questions

Based on your research, ask me any questions needed to resolve ambiguity before writing the spec. Cover:

- Scope boundaries (what's in, what's out)
- UX decisions that aren't obvious from the request
- Technical trade-offs worth discussing
- Anything that could go two reasonable ways

Wait for my answers before proceeding.

### Step 5: Write the draft spec

Create the spec file in the **current repository** at:

```
specs/YYYY-MM-DD_<SLUG>.md
```

Where `YYYY-MM-DD` is today's date and `<SLUG>` is a short lowercase-hyphenated description (e.g. `specs/2026-03-04_entry-pagination.md`).

Create the `specs/` directory if it doesn't exist.

Use this structure (skip sections that don't apply):

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
Focus on the WHY — these are the most valuable part of the spec.>

## Implementation Plan

<Numbered steps with file paths and code snippets. Each step should be small enough to
implement and verify independently. Include model changes, controller changes, frontend
changes, and tests.>

## What We're NOT Doing

<Explicitly scope out things that might seem related but are deferred or out of scope.>

## Risks & Edge Cases

<Things that could go wrong or need special handling.>

## Estimate

<Rough time estimate broken down by step.>
```

The spec lives here so you can edit it with vim, iterate, and refine. When it's ready, use `/spec-save` to move it to the Wiki.
