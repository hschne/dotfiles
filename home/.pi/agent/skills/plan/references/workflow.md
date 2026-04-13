# Plan Workflow

Follow this process unless the user explicitly asks to skip part of it.

## 1. Confirm the request

Identify:

- what is being planned
- whether the user wants a local `./plans/` file or just an in-chat draft
- any fixed constraints, priorities, or deadlines

If the user already provided this, do not ask again.

## 2. Explore the codebase first

Before writing the plan, verify the current state in code.

Read the relevant files, search for existing implementations, and check any project-specific notes needed to understand the request.

## 3. Ask clarifying questions when needed

Do not ask generic questions. Ask only what is required to resolve plan structure.

You must ask follow-up questions when any of these are unclear:

- step ordering or dependency direction
- whether related cleanup belongs in the same plan
- whether the work should be one step or split across multiple deployable steps
- naming, ownership, or architectural placement
- explicit scope boundaries

Good question examples:

- "Should the bottom-sheet cleanup and map-context merge be one step or two?"
- "Do you want the plan to include deleting the helper files, or leave deletion for a follow-up?"
- "Should this plan include behavior-preserving cleanup only, or also the snap-point model change?"

Bad question examples:

- "Can you tell me more?"
- "Any other thoughts?"
- "What do you want to do?"

## 4. Choose the step structure

Prefer 2–5 top-level steps.

Use more than 5 only when the work clearly breaks into several independently shippable phases.

Each top-level step should:

- represent a coherent unit of work
- have a clear outcome
- be testable or manually verifiable
- avoid mixing unrelated concerns

If the user gives structural feedback, rewrite the step layout cleanly instead of patching the old structure.

## 5. Write only the final plan

The final saved plan should be the clean result, not a transcript of your exploration.

Keep background short. The plan is for execution.

## 6. Validate before finishing

Before returning the plan, confirm:

- the file name matches `YY-MM-DD-<slug>.md`
- the plan uses the required headings
- steps are numbered and actionable
- each step includes file paths, changes, and acceptance criteria
- non-goals and risks are explicit
- the structure reflects user feedback exactly
