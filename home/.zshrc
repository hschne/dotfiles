# First things first, add locality script
export PATH="$HOME/.scripts:$PATH"

# Activate vi mode and set some shortcuts
bindkey -v

# Enable autocomplete and bash compatibilty
fpath=(~/.config/completions $fpath)
autoload -U +X compinit && compinit -i

autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Zi
#
# Zi is a modern plugin manager for ZSH. 
#
# Website: https://z-shell.pages.dev/
zi_home="${HOME}/.zi"
source "${zi_home}/bin/zi.zsh"

# Enable system clipboard for Vi Mode
#
# See https://github.com/kutsan/zsh-system-clipboard
zi load "kutsan/zsh-system-clipboard"

# FZF
#
# FZF is a fuzzy command line finder. Great for finding files
# and traversing your history.
#
# Website: https://github.com/junegunn/fzf
zi pack src"shell/key-bindings.zsh" for fzf 

# Plugins from oh-my-zsh
#
# Various plugins for different things, add aliases, auto-completions and stuff 
# like that.
#
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins
zi snippet OMZ::lib/git.zsh
zi snippet OMZ::plugins/git/git.plugin.zsh
zi snippet OMZ::plugins/heroku/heroku.plugin.zsh
zi snippet OMZ::plugins/rails/rails.plugin.zsh

# Syntax Highlighting and Autosuggestions
#
# Does what it says on the tin. See site for more information. Take care
# with those defers, these plugins tend to break other stuff.
#
# Website: https://github.com/zsh-users
zi load zsh-users/zsh-completions
zi load zsh-users/zsh-autosuggestions
zi load zsh-users/zsh-syntax-highlighting

# Homeshick
#
# Homeshick is a dotfile manager written in Bash. Useful for 
# keeping your settings backed up.
#
# Website: https://github.com/andsens/homeshick
zi ice pick"homeshick.sh"; zi load "andsens/homeshick"
zi ice pick"completions"; zi load "andsens/homeshick"

# You-Should-Use
#
# Plugin that reminds you to use your aliases. Will notify you 
# if there is an alias for some command that you use. 
#
# Website: https://github.com/MichaelAquilina/zsh-you-should-use
zi ice pick"you-should-use.plugin.zsh"; zi load "MichaelAquilina/zsh-you-should-use"

# fzf-tab 
#
# Replace all tab completions with fzf
#
# See https://github.com/Aloxaf/fzf-tab
zi load "Aloxaf/fzf-tab"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'fzf-tab-preview $realpath'
zstyle ':fzf-tab:complete:bat:*' fzf-preview 'fzf-tab-preview $realpath'

# Set editor to the obvious choice
export EDITOR='nvim'

# History Tweaks 
#
# The main idea here is to avoid having a bunch of duplicates.
# Additionally, the history size is increased. 
#
# See http://zsh.sourceforge.net/Doc/Release/Options.html
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
export HISTFILE=~/.zsh_history # Required when using zplug
export HISTSIZE=10000
export SAVEHIST=10000
setopt share_history

# Enable advanced cd behaviour
setopt auto_cd

# Needed for some substitutions
setopt re_match_pcre

# Disable waiting dots
# 
# This would print '...' while waiting for autocomplete, which is 
# pretty annoying 
COMPLETION_WAITING_DOTS="false"

# Disable Scroll Lock 
#
# Needed to be able to do CTRL-S in vim in the terminal. 
#
# See https://unix.stackexchange.com/a/72092
stty -ixon

# Speed up prompt redraw, useful when using vi-mode 
export KEYTIMEOUT=1

# Add custom aliases
source $HOME/.aliases

# Refresh homeshick every two days
homeshick --quiet refresh 2

# Zoxide 
#
# Autojump alternative. Use zo as command to avoid conflicts with zinit, see .aliases
#
# See https://github.com/ajeetdsouza/zoxide
[[ $(command -v "zoxide") != "" ]] && eval "$(zoxide init zsh --cmd cd)"

# Walk
#
# See https://github.com/antonmedv/walk 
function lk {
  cd "$(walk --icons "$@")"
}

# Navi
#
# Cheatsheets for the command line.
#
# See https://github.com/denisidoro/navi
[[ $(command -v "navi") != "" ]] && eval "$(navi widget zsh)"

# Improve look of fzf, use rg
export FZF_DEFAULT_OPTS='--height 50% --ansi'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--layout default --preview 'bat -n --color=always {}' --bind 'ctrl-/:toggle-preview'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window up:3::wrap --bind 'ctrl-/:toggle-preview' --color header:italic"
# Use tmux popup of in tmux
export FZF_TMUX_OPTS='-p60%,50%'

# Set up asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Export variables for scripts
export PATH="$HOME/.local/bin:$PATH"
export FLYCTL_INSTALL="/home/hschne/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
source "$HOME/.scripts/gitscripts"
# Load global environment variables
source "$HOME/.env"

# Enable colors for tmux
#
# See here: https://github.com/zsh-users/zsh-autosuggestions/issues/229#issuecomment-300675586
export TERM=xterm-256color

# Starship Prompt
#
# Minimal fast prompt. The spiritual successor to spaceship prompt.  
#
# See https://github.com/starship/starship
eval "$(starship init zsh)"

# Gcloud SDK
export PATH="$HOME/Programs/google-cloud-sdk/bin:$PATH"
if [ -f '/home/hschne/Programs/google-cloud-sdk/path.zsh.inc' ]; then . '/home/hschne/Programs/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/home/hschne/Programs/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/hschne/Programs/google-cloud-sdk/completion.zsh.inc'; fi
