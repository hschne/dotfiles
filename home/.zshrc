# Zplug
# 
# Zplug is a modern plugin manager for ZSH. 
#
# Website: https://github.com/zplug/zplug
source $HOME/.zplug/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Plugins from oh-my-zsh
#
# Various plugins for different things, add aliases, auto-completions and stuff 
# like that.
#
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/ubuntu", from:oh-my-zsh

# Enable vi-mode
#
# Allows you to havigate your shell with vim-like keybindings and feel like a wizard
# while doing it.
#
# See https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/vi-mode/vi-mode.plugin.zsh
#
# Currently causes interference with FZF, see https://github.com/robbyrussell/oh-my-zsh/issues/7137,
# thats why commit is frozen.
zplug "plugins/vi-mode", from:oh-my-zsh, at:3cd8eaf 

# Syntax Highlighting and Autosuggestions
#
# Does what it says on the tin. See site for more information.
#
# Website: https://github.com/zsh-users
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions", defer:0
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Homeshick
#
# Homeshick is a dotfile manager written in Bash. Useful for 
# keeping your settings backed up.
#
# Website: https://github.com/andsens/homeshick
zplug "andsens/homeshick", use:"homeshick.sh", defer:0
zplug "andsens/homeshick", use:"completions", defer:0

# NVM 
# 
# NVM is a version manager for node. This zsh plugin
# takes care of the installation and configuration.
# 
# See https://github.com/lukechilds/zsh-nvm
zplug "lukechilds/zsh-nvm"

# Rbenv
#
# Rbenv is a version manager for Ruby. This zsh plugin manages
# installation and configuration.
#
# Website: https://github.com/rbenv/rbenv
zplug "cswl/zsh-rbenv"

# Spaceship theme
#
# The nicest prompt theme I could find. Adds wonderful git support, 
# supports vi-mode and much more.
#
# Website: https://denysdovhan.com/spaceship-prompt/
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, as:theme

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

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

# Enable advanced cd behaviour
setopt auto_cd

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
source $HOME/.aliases

# Add custom scripts
export PATH="$HOME/.scripts:$PATH"

# Refresh homeshick every two days
homeshick --quiet refresh 2

# Pyenv
# 
# Pyenv is a version manager for Python.
#
# Website: https://github.com/pyenv/pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
export PATH="$HOME/.local/bin:$PATH"

# jEnv
#
# A version manager for Java. 
#
# Website: http://www.jenv.be/
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# The Fuck
#
# The most magnificent thing you will ever see. Semantically correct
# way of dealing with typos.
#
# Website: https://github.com/nvbn/thefuck
eval $(thefuck --alias)

# FZF
#
# FZF is a fuzzy command line finder. Great for finding files
# and traversing your history.
#
# Website: https://github.com/junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Hub
#
# Hub makes working with Github easier. This is a fix for an 
# issue with zsh, see https://github.com/robbyrussell/oh-my-zsh/issues/766
#
# Website: https://hub.github.com/
function git() { hub $@; }

# Autojump
#
# Autojump is a utility for navigating directories. It learns.
#
# Website: https://github.com/wting/autojump
[[ -s /home/hans/.autojump/etc/profile.d/autojump.sh ]] && source /home/hans/.autojump/etc/profile.d/autojump.sh
