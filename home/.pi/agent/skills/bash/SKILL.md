---
name: bash
description: "Write concise bash scripts following established conventions. Use when writing new bash scripts, shell utilities, or CLI tools."
---

# Bash Scripting

When writing bash scripts, follow these conventions. Inspect scripts such as the following as guidelines:

- ~/.scripts/mdt
- ~/.scripts/worktree

## Shell and Settings

- Use `#!/usr/bin/env bash` as the shebang.
- Use `set -euo pipefail` to ensure the script exits on errors, undefined variables, and pipe failures.

## Structure

- Use a `main` function to wrap the core logic.
- Call `main "$@"` at the bottom, protected by a check if the script is being executed directly: `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`.
- Define helper functions for repeatable tasks (e.g., `die`, `warn`, `usage`).

## Error Handling

- Use a `die` function to print errors to stderr and exit:
  ```bash
  die() {
    echo "Error: $1" >&2
    exit "${2:-1}"
  }
  ```

## Argument Parsing

- Use a `while` loop with `case` for flag parsing.
- Provide a `usage` function with a heredoc for help output.

## Style & Patterns

- Prefer `local` variables within functions.
- Use `[[ ... ]]` for tests instead of `[ ... ]`.
- Use `$(...)` for command substitution instead of backticks.
- Quote variables to prevent word splitting: `"$VAR"`.
- For interactive selections, use `fzf`.
- Avoid superfluous comments.
- When using `fzf`, check if it's installed and available.

## Common Paths

- Projects Wiki: `~/Documents/Wiki/projects`
- Scripts: `~/.scripts`
