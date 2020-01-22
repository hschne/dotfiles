# First things first, add locality script
export PATH="$HOME/.scripts:$PATH"

# Activate vi mode and set some shortcuts
bindkey -v

# Enable autocomplete and bash compatibilty
autoload compinit && compinit
autoload bashcompinit
bashcompinit

# Zinit
#
# Zinit is a modern plugin manager for ZSH. 
#
# Website: https://github.com/zdharma/zinit
source "$HOME/.zinit/bin/zinit.zsh"

# Enable system clipboard for Vi Mode
#
# See https://github.com/kutsan/zsh-system-clipboard
zinit load "kutsan/zsh-system-clipboard"

# FZF
#
# FZF is a fuzzy command line finder. Great for finding files
# and traversing your history.
#
# Website: https://github.com/junegunn/fzf
zinit ice from"gh-r" as"program"
zinit load junegunn/fzf-bin
zinit ice pick"shell/completion.zsh" src"shell/key-bindings.zsh"
zinit load junegunn/fzf

# Plugins from oh-my-zsh
#
# Various plugins for different things, add aliases, auto-completions and stuff 
# like that.
#
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/heroku/heroku.plugin.zsh
zinit snippet OMZ::plugins/rails/rails.plugin.zsh

# Syntax Highlighting and Autosuggestions
#
# Does what it says on the tin. See site for more information. Take care
# with those defers, these plugins tend to break other stuff.
#
# Website: https://github.com/zsh-users
zinit load zsh-users/zsh-completions
zinit load zsh-users/zsh-autosuggestions
zinit load zsh-users/zsh-syntax-highlighting

# The Fuck
#
# The most magnificent thing you will ever see. Semantically correct
# way of dealing with typos.
#
# Website: https://github.com/nvbn/thefuck
zinit snippet OMZ::plugins/thefuck/thefuck.plugin.zsh

# Emoji-CLI
#
# Emojis for the command line. Yes, this is absolutely needed.
#
# Website: https://github.com/b4b4r07/emoji-cli
zinit ice from"gh-r" as"program" mv "jq* -> jq"; zinit load "stedolan/jq"
zinit ice has'jq'; zinit load "b4b4r07/emoji-cli"

# Emojis for the command line, also super important.
zinit ice as"program" pick"emojify"; zinit load "mrowa44/emojify"

# Homeshick
#
# Homeshick is a dotfile manager written in Bash. Useful for 
# keeping your settings backed up.
#
# Website: https://github.com/andsens/homeshick
zinit ice pick"homeshick.sh"; zinit load "andsens/homeshick"
zinit ice pick"completions"; zinit load "andsens/homeshick"

# You-Should-Use
#
# Plugin that reminds you to use your aliases. Will notify you 
# if there is an alias for some command that you use. 
#
# Website: https://github.com/MichaelAquilina/zsh-you-should-use
zinit ice pick"you-should-use.plugin.zsh"; zinit load "MichaelAquilina/zsh-you-should-use"

# Locality
#
# Useful if you have customizations that only apply to some workstations. 
#
# See: https://github.com/hschne/locality
zinit load "hschne/locality"

# fzf-git
#
# Nice, fuzzy autocompletions for git commands.  
#
# See: https://github.com/hschne/fzf-git
zinit ice pick"fzf-git.plugin.zsh"; zinit load "hschne/fzf-git"

# fzf-tab 
#
# Replace all tab completions with fzf
#
# See https://github.com/Aloxaf/fzf-tab
zinit load "Aloxaf/fzf-tab"


# Enhancd
#
# Helps you with cd. Alternative to autojump.
# 
# Website: https://github.com/b4b4r07/enhancd
zinit light "b4b4r07/enhancd"


# Set editor to the obvious choice
export EDITOR='vim'

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

# Fix new Tab on Arch
#
# When opening a new Tab in Gnome Terminal, it always opens in $HOME. 
# Only applies to Arch distros.
#
# For the bugreport see https://bugs.launchpad.net/ubuntu-gnome/+bug/1193993 
# For fixes see  https://unix.stackexchange.com/questions/93476/gnome-terminal-keep-track-of-directory-in-new-tab
if [ -f "/etc/arch-release" ]; then
  . /etc/profile.d/vte.sh
fi

# Speed up prompt redraw, useful when using vi-mode 
export KEYTIMEOUT=1

# Add custom aliases
source $HOME/.custom.zsh
source $HOME/.aliases


# Refresh homeshick every two days
homeshick --quiet refresh 2

# Enable direnv
#
# See https://github.com/direnv/direnv
[[ $(command -v "direnv") != "" ]] && eval "$(direnv hook zsh)"

# Hub
#
# Hub makes working with Github easier. This is a fix for an 
# issue with zsh, see https://github.com/robbyrussell/oh-my-zsh/issues/766
#
# Website: https://hub.github.com/
function git() { hub $@; }

# Improve look of fzf, especially for enhancd
export FZF_DEFAULT_OPTS='--height 50% --ansi'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

# Enable colors for tmux
#
# See here: https://github.com/zsh-users/zsh-autosuggestions/issues/229#issuecomment-300675586
export TERM=xterm-256color


# Export variables for stack
export PATH="$HOME/.local/bin:$PATH"

# Enable ASDF
#
# See https://asdf-vm.com/
. $HOME/.asdf/asdf.sh echo -e 
. $HOME/.asdf/completions/asdf.bash

# Starship Prompt
#
# Minimal fast prompt. The spiritual successor to spaceship prompt.  
#
# See https://github.com/starship/starship
eval "$(starship init zsh)"


# Install ZInit if its not already there
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p $HOME/.zinit
    command git clone https://github.com/zdharma/zinit $HOME/.zinit/bin && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
