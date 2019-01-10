#!/usr/bin/sh

# This file exists so that I can properly start gvim from within Idea
# 
# Its actually a bit funny. Turns out that gvim inherits its path from whatever
# application launches it. If you just run gvim from the terminal, you get those 
# path variables. 
# 
# Normally launching gvim (via desktop) also inherits path variables, for god knows
# what reason. 
# 
# Alas, Idea (and friends) use some dark trickery to launch external applications
# and dark trickery does obviously NOT inherit any path variables. 
# 
# Which is why we create this script which sets the path variables instead. So
# we can actually use our plugins which rely on python, ruby etc. which all 
# require the path to be properly set. Well. 
PATH="/home/hans/.pyenv/shims:/home/hans/.pyenv/bin:$PATH"
PATH="/home/hans/.rbenv/shims:/home/hans/.rbenv/bin:$PATH"

lineNumber=$1
filePath=$2

gvim +"$lineNumber" "$filePath"
