---
name: review-plan
description: "Review an implementation plan against the current codebase. Use when asked to review, sanity-check, or validate a plan before coding starts."
---

# Review Plan

Compare a plan file against the current codebase. Report mismatches, risks, and required corrections.

## Workflow

### 1. Read the plan

```bash
read plans/<plan-file>.md
```

Capture: goal, naming, migration strategy, associations, deletion semantics, test expectations.

### 2. Scan the codebase

Find all references to concepts in the plan:

```bash
rg -n "ModelName|table_name|method_name|scope_name" app db test config -S
```

Read every relevant file with `read` — don't guess from grep hits alone.

### 3. Compare plan vs code

For each plan step, determine:

- **Already implemented** — code matches plan
- **Not implemented** — plan describes future state
- **Contradicts** — code does something different than plan assumes

### 4. Check for issues

Run through this checklist:

- [ ] Naming is consistent and doesn't collide with existing domain terms
- [ ] Migration strategy matches constraints (destructive ok? data to migrate?)
- [ ] `dependent:` / `on_delete:` cascades behave correctly in **every** flow (creation, redemption/transition, cleanup)
- [ ] Scopes/visibility logic still matches product behavior
- [ ] Controller/job responsibilities are clear
- [ ] Tests to delete, update, and add are explicitly listed in the plan
- [ ] Fixtures, schema, and locales that need changes are called out

### 5. Report findings

Use this structure:

1. **Summary** — one sentence: plan is sound / has issues
2. **Critical issues** — numbered, highest impact first, with file references
3. **Implementation status** — what exists today vs what plan assumes
4. **Recommended plan changes** — concrete edits (naming, associations, migration, tests)

## Common pitfalls

- **Wrong cascade direction** — marker deletion unintentionally destroys canonical data
- **Name collisions** — plan reuses a term that already means something else in the codebase
- **Implicit test impact** — plan says "simple refactor" but test changes are broad
- **Destructive migration without acknowledgment** — plan drops tables without stating data loss is acceptable
- **Stale copy/messages** — success messages or locale strings still reflect old behavior
