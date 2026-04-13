# Plan Template

Save plans under `./plans/` using `YY-MM-DD-<slug>.md`.

Example names:

- `plans/26-03-01-refactor-map-view.md`
- `plans/26-02-15-allow-password-resets.md`

## Required Structure

```markdown
# <Title>

## Goal

<What this achieves and why — 2-3 sentences max>

## Tasks

1. **Step 1**: Description
   - File: `path/to/file.ts`
   - Changes: What to modify and how. Include relevant, non-trivial snippets when useful.
   - Acceptance: How to verify

2. **Step 2**: Description
   - File: `path/to/file.ts`
   - Changes: What to modify and how. Include relevant, non-trivial snippets when useful.
   - Acceptance: How to verify

## Files to Modify

- `path/to/file.rb` - what changes.

## New Files (if any)

- `path/to/new.rb` - purpose

## What We're NOT Doing

<Explicitly scope out related work that is deferred or out of scope.>

## Risks & Edge Cases

<Things that could go wrong or need special handling.>
```

## Writing Rules

- Prefer 2–5 top-level steps.
- Use sub-tasks only when a single top-level step genuinely needs internal sequencing.
- Keep each step small and actionable.
- Prefer concrete file-level changes over abstract architecture prose.
- Each step must include acceptance criteria.
- Avoid long background sections unless they are necessary to explain the step breakdown.

## Good Pattern

```markdown
## Tasks

1. **Step 1**: Move bottom-sheet controller state into the native context
   - File: `app/javascript/components/bottom-sheet/context.svelte.ts`
   - Changes: Create a class-backed context that owns snap-point state and app-facing helpers such as `collapse`, `setHalf`, and `expand`.
   - Acceptance: Mobile sheet consumers can import the native context and no longer depend on `app/javascript/lib/bottom_sheet_context.svelte.ts`.

2. **Step 2**: Remove helper imports from layout and pages
   - File: `app/javascript/pages/layout.svelte`
   - Changes: Replace `~/lib/bottom_sheet_context.svelte` imports with the native bottom-sheet context API and keep existing drag-collapse behavior intact.
   - Acceptance: `rg "lib/bottom_sheet_context" app/javascript` returns no results.
```

## Bad Pattern

```markdown
## Tasks

### Architecture

Long narrative about the desired system.

### Refactor notes

More prose without file-level changes or acceptance criteria.
```

## Validation Checklist

Use this before finishing:

- title is specific
- goal is 2–3 sentences max
- tasks are numbered
- steps are actionable
- file paths are explicit
- acceptance criteria exist for every step
- files-to-modify list is complete
- non-goals are explicit
- risks mention likely failure modes or tricky transitions
