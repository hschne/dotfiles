---
name: tmux
description: "Use tmux to create windows or panes and start pi in specific directories. Use when the user asks to start another agent in a worktree, open a new tmux pane, split windows, inspect tmux sessions, or automate terminal layout."
---

# Tmux Skill

Use `tmux` directly when the user wants terminal multiplexing.

## Inspect tmux state

List sessions:

```bash
tmux list-sessions
```

List windows in a session:

```bash
tmux list-windows -t <session>
```

List panes in a window:

```bash
tmux list-panes -t <session>:<window>
```

## Start a new agent in a worktree

New window in current session:

```bash
tmux new-window -c /absolute/path/to/worktree -n <name> 'pi'
```

Split current window vertically:

```bash
tmux split-window -v -c /absolute/path/to/worktree 'pi'
```

Split current window horizontally:

```bash
tmux split-window -h -c /absolute/path/to/worktree 'pi'
```

Start with an initial prompt:

```bash
tmux new-window -c /absolute/path/to/worktree -n <name> "pi 'continue working on this task'"
```

## Useful tmux commands

Select tiled layout:

```bash
tmux select-layout tiled
```

Rename a window:

```bash
tmux rename-window <name>
```

Send keys to an existing pane:

```bash
tmux send-keys -t <pane-target> 'bundle exec rails test' C-m
```

Kill a pane or window:

```bash
tmux kill-pane -t <pane-target>
tmux kill-window -t <window-target>
```

## Notes for agents

- Prefer absolute paths with `-c` so the pane starts in the correct worktree.
- Check whether tmux is already running before assuming a session exists.
- If the user asks to start an agent in a worktree, first create or locate the worktree, then open a new tmux pane or window there.
- Be explicit about whether you created a new session, window, or pane.
- Do not kill panes or windows unless the user asked for cleanup.
