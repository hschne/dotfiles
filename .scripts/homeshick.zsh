# Homeshick helpers
#
# Convenience functions for managing dotfiles with homeshick.
# Assumes a single castle called 'dotfiles'.

HOMESHICK_CASTLE="$HOME/.homesick/repos/dotfiles/home"

_homeshick_pending() { printf "\e[1;36m%13s\e[0m %s" "$1" "$2"; }
_homeshick_success() { printf "\r\e[1;32m%13s\e[0m %s\n" "$1" "$2"; }
_homeshick_error()   { printf "\r\e[1;31m%13s\e[0m %s\n" "$1" "$2" >&2; }

# Open (cd into) dotfiles castle
hod() { homeshick cd dotfiles; }

# Pull dotfiles
hpd() { homeshick pull dotfiles; }

# Link dotfiles
hld() { homeshick link dotfiles; }

# Track a file or directory in dotfiles
htd() { homeshick track dotfiles "$@"; }

# Unlink a file or directory from dotfiles
#
# Copies the actual file back from the castle to its original location
# and removes it from the castle repo.
hud() {
  local target="$1"
  local relpath="${target#$HOME/}"

  if [[ -z "$target" ]]; then
    _homeshick_error "error" "Usage: hud <file|directory>"
    return 1
  fi

  if [[ ! -L "$target" ]]; then
    _homeshick_error "error" "$relpath is not a symlink"
    return 1
  fi

  local castle_path
  castle_path="$(readlink -f "$target")"

  if [[ "$castle_path" != "$HOMESHICK_CASTLE"/* ]]; then
    _homeshick_error "error" "$relpath does not point into the dotfiles castle"
    return 1
  fi

  _homeshick_pending "unlink" "$relpath"
  rm "$target"
  cp -r "$castle_path" "$target"
  rm -rf "$castle_path"
  _homeshick_success "unlink" "$relpath"
}

# Permanently delete a file or directory from dotfiles
#
# Removes both the symlink and the backing file in the castle.
# Nothing remains.
hdd() {
  local target="$1"
  local relpath="${target#$HOME/}"

  if [[ -z "$target" ]]; then
    _homeshick_error "error" "Usage: hdd <file|directory>"
    return 1
  fi

  if [[ ! -L "$target" ]]; then
    _homeshick_error "error" "$relpath is not a symlink"
    return 1
  fi

  local castle_path
  castle_path="$(readlink -f "$target")"

  if [[ "$castle_path" != "$HOMESHICK_CASTLE"/* ]]; then
    _homeshick_error "error" "$relpath does not point into the dotfiles castle"
    return 1
  fi

  _homeshick_pending "delete" "$relpath"
  rm "$target"
  rm -rf "$castle_path"
  _homeshick_success "delete" "$relpath"
}
