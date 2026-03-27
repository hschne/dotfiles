---
name: worktree
description: "Create, set up, diff, clean up, and integrate git worktrees using ~/.scripts/worktree. Use when a user asks to open a new worktree, work in a separate tree, compare a worktree to main, create a PR from a worktree, merge changes back, or delete a worktree."
---

# Worktree Skill

Use `~/.scripts/worktree` for the standard worktree workflow.

## Commands

Create a new worktree folder:

```bash
~/.scripts/worktree new "feature description"
```

Set up a worktree after creation:

```bash
~/.scripts/worktree setup <worktree-directory>
```

Compare a worktree to main (or working tree vs HEAD if there are unstaged changes):

```bash
~/.scripts/worktree diff <worktree-directory>
```

Open a worktree in tmuxinator:

```bash
~/.scripts/worktree open <worktree-directory>
```

Delete a worktree:

```bash
~/.scripts/worktree destroy <worktree-directory>
```

## Workflow

1. Create a new worktree.
2. Run setup inside that worktree.
3. Do the requested work inside the worktree.
4. Review changes with `worktree diff`.
5. Either:
   - create a PR from the worktree branch, or
   - integrate the changes directly into main, usually with a squash merge.
6. Clean up by deleting the worktree.

## Notes for agents

- `worktree new` only creates the git worktree and branch. It does not start tmux or another agent.
- Run `worktree setup` explicitly after creating the worktree.
- In this project, `bin/worktree-setup` copies `config/master.key` and the SQLite development database from the main checkout before running `bin/rails db:prepare`.
- When asked to create a PR, commit in the worktree, push the branch, then use the `gh` skill.
- When asked to integrate directly into main, use a deliberate git workflow.
- When asked to clean up, ensure no uncommitted work is being lost before destroying the worktree.
- **`FIX:` comments**: Hans may leave `# FIX: ...` comments directly in source files while reviewing a diff. Always grep for these before starting work: `grep -r "FIX:" .` — address each one, then remove the comment.

## Typical agent flow

```bash
~/.scripts/worktree new "improve login flow"
~/.scripts/worktree setup 26-03-improve-login-flow
cd worktrees/26-03-improve-login-flow
~/.scripts/worktree diff 26-03-improve-login-flow
```
