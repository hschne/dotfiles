---
name: plan
description: Write implementation plans for project work. Use when the user asks for a plan, wants work broken into steps, or needs a scoped implementation roadmap saved under `./plans/`.
---

# Plan

Use this skill to write concise, implementation-ready plans.

## When to Use This Skill

- The user asks to "make a plan"
- The user wants implementation work split into steps
- The user wants a roadmap saved in `./plans/`

## Core Rules

- Do not draft the plan immediately unless the user explicitly wants a rough draft.
- First gather code and project context.
- Ask clarifying questions for any unresolved structural or sequencing decision.
- Rewrite plans to match user feedback; do not patch a bad structure incrementally.
- Final plans must follow the template exactly.
- Prefer 2–5 top-level numbered steps over long narrative subsections.
- Each step should be small, actionable, and independently verifiable.
- Be concrete about files, changes, and acceptance criteria.

## Workflow

1. Confirm the planning target and any constraints.
2. Explore the codebase to verify the current state.
3. Ask clarifying questions until sequencing and scope are clear.
4. Sketch the affected modules and choose the smallest sensible step breakdown.
5. Write the final plan in `./plans/YY-MM-DD-<slug>.md` using the template.
6. Re-read the plan and check it against the validation list before finishing.

## Validation and Iteration

Before finishing a plan:

- verify the file name matches `YY-MM-DD-<slug>.md`
- verify the required headings are present
- verify every step includes files, changes, and acceptance criteria
- verify the structure reflects the user's latest feedback exactly
- if the structure is wrong, rewrite the plan cleanly instead of patching it

## References

Use the focused reference that matches the task:

| Topic    | Description                                                             | Reference                          |
| -------- | ----------------------------------------------------------------------- | ---------------------------------- |
| workflow | Required planning process, questions, and decision gates before writing | [workflow](references/workflow.md) |
| template | Exact plan structure, naming, and validation checklist                  | [template](references/template.md) |
