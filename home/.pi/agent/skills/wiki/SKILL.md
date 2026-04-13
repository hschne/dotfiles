---
name: wiki
description: Manage Hans's personal knowledge base at `~/Documents/Wiki/`. Use when Hans needs to save documents, retrieve prior decisions or context, or search the wiki with QMD.
---

# Wiki

Use this skill to store and retrieve knowledge in Hans's wiki.

## When to Use This Skill

- Hans asks to save a spec, plan, runbook, note, or decision document
- Hans asks for past context, previous decisions, or prior research
- You want to check the wiki before duplicating work or making a decision
- You need to search or fetch wiki documents with QMD

## Core Rules

- Save documents under `~/Documents/Wiki/` using the standard collection layout.
- Choose the destination path from the user's intent before writing.
- Use concise, descriptive, lowercase hyphenated file names.
- After adding or editing files, run `qmd update`.
- Run `qmd embed` only when semantic or hybrid retrieval must include newly added content.
- Prefer `qmd search` first; escalate to `qmd query` or `qmd vsearch` when needed.
- Search `archive` only when the user asks for inactive or historical material.

## Workflow

1. Identify whether the task is storage, retrieval, or both.
2. Read the matching reference for location rules or QMD usage.
3. Write or retrieve the document using the prescribed path or command pattern.
4. If files changed, refresh the QMD index with the appropriate command.
5. Validate that the saved path or retrieved results match the user's intent.

## Validation and Iteration

Before finishing:

- verify the destination collection and subfolder are correct
- verify the file name follows the expected naming convention
- verify `qmd update` was run after file changes
- verify retrieval used the narrowest useful collection scope
- if results are weak, refine the query or switch retrieval mode

## References

Use the focused reference that matches the task:

| Topic     | Description                                                 | Reference                            |
| --------- | ----------------------------------------------------------- | ------------------------------------ |
| structure | Wiki collections, path conventions, and where documents go  | [structure](references/structure.md) |
| storage   | Save workflows, naming rules, and index refresh behavior    | [storage](references/storage.md)     |
| retrieval | QMD search, query modes, retrieval commands, and heuristics | [retrieval](references/retrieval.md) |
