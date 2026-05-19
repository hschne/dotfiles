# vim:fileencoding=utf-8:foldmethod=marker

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
zi ice lucid wait
zi load "kutsan/zsh-system-clipboard"
#: }}}

#: OH MY ZSH PLUGINS {{{
#
# Various plugins for different things, add aliases, auto-completions and stuff 
# like that.
#
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins
zi snippet OMZP::archlinux/archlinux.plugin.zsh
zi snippet OMZL::git.zsh
zi snippet OMZP::git/git.plugin.zsh
zi snippet OMZP::npm/npm.plugin.zsh
zi snippet OMZP::rails/rails.plugin.zsh
zi ice as"completion"
zi snippet OMZP::rails/_rails
#: }}}

#: SYNTAX HIGHLIGHTING AND AUTOSUGGESTIONS {{{
#
# Does what it says on the tin. See site for more information. Take care
# with those defers, these plugins tend to break other stuff.
#
# Website: https://github.com/zsh-users
zi ice lucid wait
zi load zsh-users/zsh-completions
zi ice lucid wait
zi load zsh-users/zsh-autosuggestions
zi ice lucid wait
zi load zsh-users/zsh-syntax-highlighting
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
# Use tmux popup of in tmux
export FZF_TMUX_OPTS='-p80%,50%'

# Default key bindings for FZF
zi pack src"shell/key-bindings.zsh" for fzf 

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

#: MISE {{{
eval "$(mise activate zsh)"
#: }}}

#: FNOX {{{
export FNOX_SHELL_OUTPUT=none
export FNOX_AGE_KEY_FILE="$HOME/.ssh/id_rsa"
eval "$(fnox activate zsh)"
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
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

#: COMPLETIONS {{{
#
# Enable autocomplete and bash compatibilty
fpath=(~/.config/completions $fpath)
autoload bashcompinit && bashcompinit
autoload -U +X compinit && compinit -i
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
