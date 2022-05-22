# First things first, add locality script
export PATH="$HOME/.scripts:$PATH"

# Activate vi mode and set some shortcuts
bindkey -v

# Enable autocomplete and bash compatibilty
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

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

# The Fuck
#
# The most magnificent thing you will ever see. Semantically correct
# way of dealing with typos.
#
# Website: https://github.com/nvbn/thefuck
zi ice wait'1' lucid
zi snippet OMZ::plugins/thefuck/thefuck.plugin.zsh

# Emoji-CLI
#
# Emojis for the command line. Yes, this is absolutely needed.
#
# Website: https://github.com/b4b4r07/emoji-cli
zi ice from"gh-r" as"program" mv "jq-* -> jq"; zi load "stedolan/jq"
zi ice has'jq'; zi load "b4b4r07/emoji-cli"

# Emojis for the command line, also super important.
zi ice as"program" pick"emojify"; zi load "mrowa44/emojify"

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

# Timewarrior
#
# Completions to work with timewarrior
zi ice pick"timewarrior.zsh"; zi light "svenXY/timewarrior"
# We need to source these completions, because zi mistakes them as compdefs
source "$HOME/.zi/plugins/svenXY---timewarrior/_timew" 

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

export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/Programs/google-cloud-sdk/bin:$PATH"

source "$HOME/.scripts/gitscripts"


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/hschne/Programs/google-cloud-sdk/path.zsh.inc' ]; then . '/home/hschne/Programs/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/hschne/Programs/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/hschne/Programs/google-cloud-sdk/completion.zsh.inc'; fi
