---
name: gh
description: "Interact with GitHub using the `gh` CLI. Supports issues, PRs, CI runs, fork-aware PR creation, upstream sync, dependabot bulk merge, and automated PR+CI+merge workflows."
---

# GitHub Skill

Use the `gh` CLI to interact with GitHub. Always specify `--repo owner/repo` when not in a git directory, or use URLs directly.

## Pull Requests

Check CI status on a PR:

```bash
gh pr checks <pr-number> --repo owner/repo
```

List recent workflow runs:

```bash
gh run list --repo owner/repo --limit 10
```

View a run and see which steps failed:

```bash
gh run view <run-id> --repo owner/repo
```

View logs for failed steps only:

```bash
gh run view <run-id> --repo owner/repo --log-failed
```

## Create a PR

```bash
gh pr create --title "Title" --body "Description"
gh pr create --fill  # Auto-fill from commits
```

## Merge a PR

Wait for CI to pass on a PR, then squash merge it:

```bash
# Get target repo (handles forks)
repo=$(gh repo view --json isFork,parent,nameWithOwner --jq 'if .isFork then .parent.owner.login + "/" + .parent.name else .nameWithOwner end')

# Wait for CI, then squash merge
gh pr checks <pr-number> --repo "$repo" --watch --fail-fast && gh pr merge <pr-number> --repo "$repo" --squash
```

## API for Advanced Queries

The `gh api` command is useful for accessing data not available through other subcommands.

Get PR with specific fields:

```bash
gh api repos/owner/repo/pulls/55 --jq '.title, .state, .user.login'
```

## JSON Output

Most commands support `--json` for structured output. Use `--jq` to filter:

```bash
gh issue list --repo owner/repo --json number,title --jq '.[] | "\(.number): \(.title)"'
```
