---
description: Create a new draft plan in plans/ — research, plan, then write
---

Create a new plan for: $@

If no topic was provided (i.e., `$@` is empty or blank), stop immediately and ask: _"What is this plan for?"_ — do not proceed until the user answers.

## Instructions

Read the plan skill first:

```
read({ path: "/home/hschne/.pi/agent/skills/plan/SKILL.md" })
```

Then follow these steps **in order**. Do NOT skip ahead to writing the plan.

### Step 1: Identify the project

Determine which project this plan belongs to from context (cwd, git remote, recent conversation, or ask me).

### Step 2: Understand the codebase

Before writing anything, research the current codebase to understand:

- What exists today (models, controllers, components, routes)
- How similar features were implemented
- What patterns and conventions are used
- What constraints exist (dependencies, data model, APIs)

Read relevant files. Run the app or tests if needed. Do NOT guess at implementation details.

Search for existing plans and context related to this topic:

```bash
qmd search "<relevant keywords>" -c projects -n 5
```

Load any plans that look relevant. Skip this if nothing looks related.

### Step 3: Ask clarifying questions

Based on your research, ask me any questions needed to resolve ambiguity before writing the plan. Cover:

- Scope boundaries (what's in, what's out)
- UX decisions that aren't obvious from the request
- Technical trade-offs worth discussing
- Anything that could go two reasonable ways

Wait for my answers before proceeding.

### Step 4: Write the draft plan

Use the file naming, structure, and location from the plan skill. Create the `plans/` directory if it doesn't exist.

The plan lives here so you the user can edit it with vim, iterate, and refine.
