# Path to your oh-my-zsh installatio
autoload -U add-zsh-hook
export ZSH=$HOME/.oh-my-zsh
setopt extended_glob

ZSH_THEME="spaceship"

BULLETTRAIN_PROMPT_ORDER=(
 time
 status
 custom
 context
 dir
 perl
 #ruby
 #virtualenv
 #nvm
 #go
 git
 hg
 cmd_exec_time
)

plugins=(
  ubuntu
  git 
  git-extras
  gitfast
  github
  docker-compose
  docker
  mvn
)

source $ZSH/oh-my-zsh.sh

# History Tweaks 
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000

# PATH
################################################################################
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/CloudStation/Synced/Scripts:$PATH"

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export PIPENV_VENV_IN_PROJECT=1 # Initialize pipenv in Project

# Init Oh My Zsh
################

# Aliases
################
source $HOME/.aliases

# CLI Tools and Tweaks
######################

# Disable scroll lock
# See https://unix.stackexchange.com/a/72092
stty -ixon

# Vim Mode
bindkey -v
export KEYTIMEOUT=1

function zle-keymap-select() {
  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select

# Homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
homeshick --quiet refresh 2

# Hub
# Fix for git alias, see https://github.com/robbyrussell/oh-my-zsh/issues/766
function git() { hub $@; }

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# jEnv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# The Fuck
eval $(thefuck --alias)

# Enable FZF Keybindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Color fix for xterm
if [ "$TERM" = "xterm" ]; then
    export TERM=xterm-256color
fi




