
# Function to format atuin output with relative timestamps
custom-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null

  local dir_key="ctrl-d"
  local session_key="ctrl-s" 
  local all_key="ctrl-a"
  
  local header="History | ${dir_key}: Directory | ${session_key}: Session | ${all_key}: All"
  local ATUIN_COMMAND="atuin history list --reverse false --format '{relativetime}\t{duration}\t{command}' --print0" 
  local UNIQUE_COMMAND="perl -0 -ne 'if (!\$seen{(/^.*\t.*\t(.*)/s, \$1)}++) { print; }'"
  local FORMAT_COMMAND="perl -0 -pe 's/\n(?!\0)/\n\t\t/g'"
  local ATUIN_ALL_COMMAND="${ATUIN_COMMAND} | ${UNIQUE_COMMAND} | ${FORMAT_COMMAND}"
  local ATUIN_DIRECTORY_COMMAND="${ATUIN_COMMAND} -c |${UNIQUE_COMMAND} | ${FORMAT_COMMAND}"
  local ATUIN_SESSION_COMMAND="${ATUIN_COMMAND} -s | ${UNIQUE_COMMAND} | ${FORMAT_COMMAND}"
  selected=$(
    eval $ATUIN_ALL_COMMAND | \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "" "${FZF_CTRL_R_OPTS-}") \
    $(__fzfcmd) \
    --delimiter="\t" \
    --read0 \
    --no-sort \
    --preview 'echo {3..} | bat -p -l bash --color=always ' \
    --preview-window 'down:5::wrap::hidden' \
    --header="${header}" \
    --bind="${dir_key}:reload(${ATUIN_DIRECTORY_COMMAND})+change-prompt(dir > )" \
    --bind="${session_key}:reload(${ATUIN_SESSION_COMMAND})+change-prompt(session > )" \
    --bind="${all_key}:reload(${ATUIN_ALL_COMMAND})+change-prompt(all > )" \
    --bind 'ctrl-/:toggle-preview' \
    --bind=ctrl-r:toggle-sort \
    --prompt="> " \
    --scheme="history" \
    --wrap-sign '\t↳ ' \
    --highlight-line \
    --accept-nth=3.. \
    --keep-right \
    --query=${LBUFFER} +m
  )
  
  local ret=$?
  if [ -n "$selected" ]; then
    # Extract just the command part (third field) and remove leading tabs in case of multi-line command
    LBUFFER="$selected"
  fi
  zle reset-prompt
  return $ret
}

zle -N custom-history-widget
bindkey '^R' custom-history-widget
