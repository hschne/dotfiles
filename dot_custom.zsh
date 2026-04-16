#!/usr/bin/env bash

GIT_COMMAND=${GIT_COMMAND:-'git'}
COPY_COMMAND=${COPY_COMMAND:-'xclip -sel clip'}

custom::gbc() {
  [[ -z $1 ]] && { custom::fail "Branch name must not be empty"; return 1; }
  local text=${1// /-}
  text=$(echo "$text" | tr '[:upper:]' '[:lower:]')
  local date
  date=$(date +"%y-%m")
  local branchname="$date-$text"

  $GIT_COMMAND checkout -b "$branchname"
}

custom::gbnc() {
  $GIT_COMMAND branch | grep \* | cut -d ' ' -f2 | xclip -sel clip
}

custom::fail() {
  local message=$1
  local code=${2:-1}
  echo "$message"
}

alias gbc="custom::gbc"
alias gbnc="custom::gbnc"
