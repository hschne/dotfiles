# vim:fileencoding=utf-8:foldmethod=marker

#: MUX-SOLO {{{
#
# Soloterm-style process status indicators in the tmux window tabs.
# Marks panes running tracked processes (set via @mux-solo-processes in
# ~/.tmux.conf) so the window tabs show a colored dot + label per pane.
#
# See https://github.com/hschne/mux-solo
source "$HOME/.tmux/plugins/mux-solo/shell/mux-solo.zsh"
#: }}}

#: ZI {{{
#
# Zi is a modern plugin manager for ZSH. 
#
# Website: https://z-shell.pages.dev/
typeset -A ZI
ZI[BIN_DIR]="${ZI_BIN_DIR:-${HOME}/.zi/bin}"
source "${ZI[BIN_DIR]}/share/zinit/zinit.zsh" 2>/dev/null || source "${ZI[BIN_DIR]}/zi.zsh"
(( ${+_comps} )) && _comps[zi]=_zi

#: }}}

#: VI MODE & CLI EDITING {{{
bindkey -v

# Better command line editing (for vi mode)
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
#: }}}

#: ENV  {{{

# Set editor to the obvious choice
export EDITOR='nvim'

# Set manpager to neovim
export MANPAGER='nvim +Man!'
export MANWIDTH=999
#: }}}

#: ALIASES  {{{
source $HOME/.aliases
#: }}}

#: PATH {{{
#
# Export variables for scripts
export PATH="$HOME/.scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.scripts/gitscripts"

#:}}}

#: HISTORY {{{
#
# The main idea here is to avoid having a bunch of duplicates.
# Additionally, the history size is increased. 
#
# See http://zsh.sourceforge.net/Doc/Release/Options.html
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME
setopt SHARE_HISTORY
export HISTFILE=~/.zsh_history # Required when using zplug
export HISTSIZE=10000
export SAVEHIST=10000
#: }}}

#: HISTDB {{{
# Store command history and metadata in SQLite.
zi load "hschne/zhstdb"
#: }}}

#: ZSH TWEAKS {{{

# Enable advanced cd behaviour
setopt auto_cd

# Needed for some substitutions
setopt re_match_pcre

# Disable waiting dots
# 
# This would print '...' while waiting for autocomplete, which is 
# pretty annoying 
COMPLETION_WAITING_DOTS="false"

# Enable colors for tmux
#
# See here: https://github.com/zsh-users/zsh-autosuggestions/issues/229#issuecomment-300675586
# export TERM=xterm-256color

# Disable Scroll Lock 
#
# Needed to be able to do CTRL-S in vim in the terminal. 

# See https://unix.stackexchange.com/a/72092
stty -ixon

# Speed up prompt redraw, useful when using vi-mode 
export KEYTIMEOUT=1
#: }}}

#: VI SYSTEM CLIPBOARD {{{
#
# See https://github.com/kutsan/zsh-system-clipboard
# Only load on desktop (clipboard managers not available on headless servers)
if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
  zi ice lucid wait
  zi load "kutsan/zsh-system-clipboard"
fi
#: }}}

#: OH MY ZSH PLUGINS {{{
#
# Various plugins for different things, add aliases, auto-completions and stuff 
# like that.
#
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins
zi ice light-mode
zi snippet OMZP::archlinux/archlinux.plugin.zsh
zi ice light-mode
zi snippet OMZL::git.zsh
zi ice light-mode
zi snippet OMZP::git/git.plugin.zsh
zi ice light-mode
zi snippet OMZP::npm/npm.plugin.zsh
zi ice light-mode
zi snippet OMZP::rails/rails.plugin.zsh
zi ice as"completion" light-mode
zi snippet OMZP::rails/_rails
#: }}}

#: EXTRA COMPLETIONS {{{
zi ice lucid wait
zi load zsh-users/zsh-completions
#: }}}

#: KAMAL COMPLETE {{{
# zi ice lucid wait as'completion' blockf has'kamal' mv'kamal.zsh -> _kamal'
# zi snippet https://github.com/hschne/kamal-complete/blob/main/completions/kamal.zsh
#: }}}

#: YOU-SHOULD-USE {{{
#
# Plugin that reminds you to use your aliases. Will notify you 
# if there is an alias for some command that you use. 
#
# Website: https://github.com/MichaelAquilina/zsh-you-should-use
zi ice pick"you-should-use.plugin.zsh"; zi load "MichaelAquilina/zsh-you-should-use"
#: }}}

#: FZF {{{
#
# The best Fuzzy Finder.
#
# Improve look of fzf, use rg
export FZF_DEFAULT_OPTS='--height=50% --ansi --reverse --style full:sharp'
# Add Tokyo Night colors
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' 
	--color=fg:#c0caf5,hl:#bb9af7,bg+:#414868
	--color=selected-bg:#7aa2f7,gutter:#24283b,border:#414868
	--color=fg+:#c0caf5,hl+:#7aa2f7
	--color=info:#7aa2f7,prompt:#7aa2f7,pointer:#7aa2f7 
	--color=marker:#73daca,spinner:#73daca,header:#73daca
  --color header:italic'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:toggle-preview'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window up:3:wrap --bind 'ctrl-/:toggle-preview'"
# Use tmux popup of in tmux
export FZF_TMUX_OPTS='-p80%,50%'

# Default key bindings for FZF (Ctrl-R history, Ctrl-T files, Alt-C cd)
# Source the system fzf shell integration with Zi, but do not install Zi's fzf binary pack.
zi ice lucid pick"key-bindings.zsh"
zi light /usr/share/fzf

bindkey -M emacs '^R' histdb-fzf-widget
bindkey -M viins '^R' histdb-fzf-widget
bindkey -M vicmd '^R' histdb-fzf-widget

# Load custom FZF Widgets
# source ~/.scripts/custom-fzf-widgets.zsh

#: }}}

#: FZF-TAB {{{
#
# Replace all tab completions with fzf
#
# See https://github.com/Aloxaf/fzf-tab
zi ice lucid wait has'fzf'
zi light Aloxaf/fzf-tab
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' popup-min-size 150 20
zstyle ':fzf-tab:*' use-fzf-default-opts no
zstyle ':fzf-tab:*' fzf-flags --color=fg:#c0caf5,hl:#bb9af7,bg+:#414868,selected-bg:#7aa2f7,gutter:#24283b,border:#414868,fg+:#c0caf5,hl+:#7aa2f7,info:#7aa2f7,prompt:#7aa2f7,pointer:#7aa2f7,marker:#73daca,spinner:#73daca,header:#73daca
zstyle ':fzf-tab:complete:(cd|eza|bat|nvim|lk):*' fzf-preview 'fzf-tab-preview ${(Q)realpath}'

#: }}}

#: AUTOSUGGESTIONS AND SYNTAX HIGHLIGHTING {{{
# Load after other ZLE plugins so autosuggestions only bind widgets once.
typeset -g ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zi ice lucid wait
zi load zsh-users/zsh-autosuggestions
zi ice lucid wait atload'_zsh_autosuggest_bind_widgets'
zi load zsh-users/zsh-syntax-highlighting
#: }}}

#: MISE {{{
# Expose mise commands before deferred activation.
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Activate mise after the first prompt. The preexec hook closes the small
# Turbo-mode race so every command still receives the mise/Fnox environment.
_mise_activate() {
  (( ${+functions[mise]} )) && return

  eval "$(command mise activate zsh)"
  add-zsh-hook -d precmd _mise_hook_precmd
  add-zsh-hook -d preexec _mise_activate
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _mise_activate
zi ice wait"0a" lucid nocd atload'_mise_activate'
#: }}}

#: FNOX {{{
export FNOX_SHELL_OUTPUT=none
#: }}}

#: ZOXIDE {{{
#
# Autojump alternative. Use zo as command to avoid conflicts with zinit, see .aliases
#
# Inlcudes workaround for Claude Code (https://github.com/anthropics/claude-code/issues/2632#issuecomment-3024225046)
#
# See https://github.com/ajeetdsouza/zoxide
[[ -z "$DISABLE_ZOXIDE" ]] && eval "$(zoxide init zsh --cmd cd)"

zo() {
  local dir=$(
    zoxide query --list --score |
    fzf --height 40% --layout reverse --info inline \
        --nth 2.. --no-sort --query "$*" \
        --bind 'enter:become:echo {2..}'
  ) && cd "$dir"
}
#: }}}

# pnpm
export PNPM_HOME="/home/hschne/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PATH:$PNPM_HOME" ;;
esac
# pnpm end

#: COMPLETIONS {{{
#
# Enable autocomplete and bash compatibility
fpath=(~/.config/completions $fpath)
# Zinit adds completion directories after this point, invalidating compinit's
# file-count check on every shell. Rebuild manually after changing completions.
autoload -Uz compinit bashcompinit
compinit -C -i
bashcompinit
source "$HOME/.config/completions/mise.zsh"
# The cached dump omits the service target used by the OMZ Rails plugin.
(( ${+_comps[rails]} )) || compdef _rails rails
zi cdreplay -q
complete -C '/usr/local/bin/aws_completer' aws
#: }}}

#: YAZI {{{
#
# Wrapper to cd into Yazi's last directory on exit.
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"

  if local cwd="$(cat -- "$tmp" 2>/dev/null)" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi

  rm -f -- "$tmp"
}
#: }}}

#: STARSHIP PROMPT {{{
#
# Minimal fast prompt. The spiritual successor to spaceship prompt.  
#
# See https://github.com/starship/starship
eval "$(starship init zsh)"

#: }}}

# sentry
fpath=("/home/hschne/.local/share/zsh/site-functions" $fpath)
