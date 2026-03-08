---
name: homeshick
description: "Manage dotfiles with homeshick. Track, unlink, and delete config files and scripts in the user's dotfiles castle. Use when the user wants to track a file, stop tracking a file, or manage their dotfiles."
---

# Homeshick Dotfiles Management

The user manages dotfiles with [homeshick](https://github.com/andsens/homeshick) — a single castle called `dotfiles`.

## How It Works

- Dotfiles live in `~/.homesick/repos/dotfiles/home/`
- Tracked files are symlinked from `~` into the castle

## Commands

All commands assume the `dotfiles` castle. These require sourcing the homeshick functions `source ~/.scripts/homeshick.zsh`

| Command           | Description                                                                 |
| ----------------- | --------------------------------------------------------------------------- |
| `htd <file\|dir>` | **Track** — move a file into the castle and replace with symlink            |
| `hud <file\|dir>` | **Unlink** — copy file back from castle, remove symlink, delete castle copy |
| `hdd <file\|dir>` | **Delete** — remove symlink AND castle copy, nothing remains                |
| `hod`             | **Open** — cd into the dotfiles castle                                      |
| `hpd`             | **Pull** — pull latest dotfiles from remote                                 |
| `hld`             | **Link** — re-symlink all dotfiles from the castle                          |

## Track a New File

```bash
htd ~/.config/foo/bar.conf
```

This moves the file into `~/.homesick/repos/dotfiles/home/.config/foo/bar.conf` and creates a symlink in its place.

## Unlink a Tracked File

```bash
hud ~/.config/foo/bar.conf
```

Copies the real file back to its original location and removes it from the castle. The file remains on disk as a regular file but is no longer tracked.

## Permanently Delete a Tracked File

```bash
hdd ~/.config/foo/bar.conf
```

Removes the symlink and deletes the backing file from the castle. The file is gone entirely.

## Directories

All commands work on directories too. Unlinking or deleting a directory applies recursively.

```bash
htd ~/.config/foo/       # Track entire directory
hud ~/.config/foo/       # Unlink entire directory
hdd ~/.config/foo/       # Delete entire directory
```

## Direct Homeshick Usage

For anything beyond the helpers above, use `homeshick` directly:

```bash
homeshick track dotfiles <file>
homeshick link dotfiles
homeshick list
homeshick check dotfiles
```

## Committing Changes

After tracking or untracking files, commit the changes:

```bash
hod                      # cd into castle
git add -A && git commit -m "message"
git push
```
