# scripts

A collection of all kinds of little scripts. Some stolen, some found, some I even made myself!

See below for more information about the contents of this repository :cookie:

## cloc-git

Count the lines of code for a given github repository. Requires [CLOC](http://cloc.sourceforge.net/) to work. 

Original Source can be found on [GitHub](https://gist.github.com/sonalkr132/73e6fac6b551ea6f7c5a).

### Usage 

```bash 
cloc-git git@github.com:user/myrepo.git
```

## hs2lhs.hs 

I used this for Functional Programming. We had to write lhs style Haskell, so my natural reaction was to not do that and instead use a script to convert 'real' Haskell source files to 'literal' style source files. Requires a Haskell interpreter to run. 

The original can be found on this [Github page](https://github.com/jeffreyrosenbluth/Literate).

### Usage

```bash
./hs2lhs myprog.hs
```

## moss.pl  

Moss is a tool for detecting software similarity (read: plagiarism). Comes in handy when checking student submissions. See [the original page](https://theory.stanford.edu/~aiken/moss/) for more information.

The script itself is well documented, so have a look for usage instructions there. 

## open-url.sh

A helper script for opening `.url` files under linux.

For installation/usage instructions see [this site](http://saidulhassan.com/open-url-files-in-linux-mint-ubuntu-1029).

## keybindings.pl

This funky little script can backup and restore Gnome keybindings into CSV.
Kindly donated by StackExchange, see [here](https://askubuntu.com/a/217310/376814).

### Usage 
```bash
# Backkup
./keybindings.pl -e /tmp/keys.csv
# Restore
./keybindings.pl -i /tmp/keys.csv
```



