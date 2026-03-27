---
name: plan
description: "Understand how plans are written. Use when writing a plan."
---

# Plan Skill

Plans are concrete documents. The clearly describe what needs to be done to archive a specific goal.

Unless otherwise stated create a `PLAN.md` with the following contents.

## Plan Structure

```markdown
# <Title>

## Goal

<What this achieves and why — 2-3 sentences max>

## Tasks

Numbered steps, each small and actionable:

1. **Task 1**: Description
   - File: `path/to/file.ts`
   - Changes: What to modify
   - Acceptance: How to verify

2. **Task 2**: Description
   ...

## Files to Modify
- `path/to/file.rb` - what changes. 
- code samples for non-trivial changes

## New Files (if any)
- `path/to/new.rb` - purpose

## What We're NOT Doing

<Explicitly scope out things that might seem related but are deferred or out of scope.>

## Risks & Edge Cases

<Things that could go wrong or need special handling.>

```

