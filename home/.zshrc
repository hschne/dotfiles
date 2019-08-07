# First things first, add locality script
export PATH="$HOME/.scripts:$PATH"

# Zplug
# 
# Zplug is a modern plugin manager for ZSH. 
#
# Website: https://github.com/zplug/zplug
source $HOME/.zplug/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Enable vi-mode
#
# Allows you to havigate your shell with vim-like keybindings and feel like a wizard
# while doing it.
#
# See https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/vi-mode/vi-mode.plugin.zsh
zplug "plugins/vi-mode", from:oh-my-zsh

# Enable system clipboard for Vi Mode
zplug "kutsan/zsh-system-clipboard"

# Enhancd
#
# Helps you with cd. Alternative to autojump.
# 
# Website: https://github.com/b4b4r07/enhancd
zplug "b4b4r07/enhancd", use:init.sh

# FZF
#
# FZF is a fuzzy command line finder. Great for finding files
# and traversing your history.
#
# Website: https://github.com/junegunn/fzf
#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
zplug "junegunn/fzf", use:"shell/*.zsh", defer:2

# Plugins from oh-my-zsh
#
# Various plugins for different things, add aliases, auto-completions and stuff 
# like that.
#
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/heroku", from:oh-my-zsh, defer:0
zplug "plugins/rails", from:oh-my-zsh

# Syntax Highlighting and Autosuggestions
#
# Does what it says on the tin. See site for more information. Take care
# with those defers, these plugins tend to break other stuff.
#
# Website: https://github.com/zsh-users
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:3

# The Fuck
#
# The most magnificent thing you will ever see. Semantically correct
# way of dealing with typos.
#
# Website: https://github.com/nvbn/thefuck
zplug "plugins/thefuck", from:oh-my-zsh, defer:1

# Emoji-CLI
#
# Emojis for the command line. Yes, this is absolutely needed.
#
# Website: https://github.com/b4b4r07/emoji-cli
zplug "b4b4r07/emoji-cli", on:"stedolan/jq", defer:2
zplug "stedolan/jq", from:gh-r, as:command, rename-to:jq

# Emojis for the command line, also super important.
zplug "mrowa44/emojify", as:command, use:emojify

# Homeshick
#
# Homeshick is a dotfile manager written in Bash. Useful for 
# keeping your settings backed up.
#
# Website: https://github.com/andsens/homeshick
zplug "andsens/homeshick", use:"homeshick.sh", defer:0
zplug "andsens/homeshick", use:"completions", defer:2

# Spaceship theme
#
# The nicest prompt theme I could find. Adds wonderful git support, 
# supports vi-mode and much more.
#
# Website: https://denysdovhan.com/spaceship-prompt/
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, as:theme

# You-Should-Use
#
# Plugin that reminds you to use your aliases. Will notify you 
# if there is an alias for some command that you use. 
#
# Website: https://github.com/MichaelAquilina/zsh-you-should-use
zplug "MichaelAquilina/zsh-you-should-use"

# Locality
#
# Useful if you have customizations that only apply to some workstations. 
#
# See: https://github.com/hschne/locality
zplug "hschne/locality"

# fzf-git
#
# Nice, fuzzy autocompletions for git commands.  
#
# See: https://github.com/hschne/fzf-git
zplug "hschne/fzf-git", defer:2

# fzf-gcloud
#
# Fuzzy autocompletions for gcloud commands.  
#
# See: https://github.com/hschne/fzf-gcloud
zplug "hschne/fzf-gcloud"

# Can't use locality here, as it is only sourced after zplug load
file="$HOME/.local.zplug"; [[ -f $file ]] && source $file;

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

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

# Load machine local configuration
locality-load "$HOME/.zshrc"

# Enable colors for tmux
#
# See here: https://github.com/zsh-users/zsh-autosuggestions/issues/229#issuecomment-300675586
export TERM=xterm-256color

# Enable bash completion script compatibility
autoload bashcompinit
bashcompinit

# Enable you-should-use-hardcore mode
export YSU_HARDCORE=1

# Enable ASDF
#
# See https://asdf-vm.com/
. $HOME/.asdf/asdf.sh echo -e 
. $HOME/.asdf/completions/asdf.bash



