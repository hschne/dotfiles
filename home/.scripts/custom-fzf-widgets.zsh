
# Function to format atuin output with relative timestamps
custom-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null

  local dir_key="ctrl-d"
  local session_key="ctrl-s" 
  local all_key="ctrl-a"
  
  local header="History | ${dir_key}: Directory | ${session_key}: Session | ${all_key}: All"
  local ATUIN_COMMAND="atuin history list --format '{relativetime}\t{duration}\t{command}' --print0" 

  local FORMAT_COMMAND="perl -0 -ne '@fields = split(/\t/, $_, 3); if (!$seen{$fields[2]}++) { s/\n(?!\0)/\n\t\t/g; print $_; }'"
  local FORMAT_COMMAND="perl -0 -pe 's/\n(?!\0)/\n\t\t/g'"
  local ATUIN_ALL_COMMAND="${ATUIN_COMMAND} | ${FORMAT_COMMAND}"
  local ATUIN_DIRECTORY_COMMAND="${ATUIN_COMMAND} -c | ${FORMAT_COMMAND}"
  local ATUIN_SESSION_COMMAND="${ATUIN_COMMAND} -s | ${FORMAT_COMMAND}"
  selected=$(
    eval $ATUIN_ALL_COMMAND | \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "" "${FZF_CTRL_R_OPTS-}") \
    $(__fzfcmd) \
    --delimiter="\t" \
    --read0 \
    --tac \
    --no-sort \
    --header="${header}" \
    --bind="${dir_key}:reload(${ATUIN_DIRECTORY_COMMAND})+change-prompt(dir > )" \
    --bind="${session_key}:reload(${ATUIN_SESSION_COMMAND})+change-prompt(session > )" \
    --bind="${all_key}:reload(${ATUIN_ALL_COMMAND})+change-prompt(all > )" \
    --bind=ctrl-r:toggle-sort \
    --prompt="> " \
    --wrap-sign '\t↳ ' \
    --highlight-line \
    --accept-nth=3.. \
    --query=${LBUFFER} +m
  )
  
  local ret=$?
  if [ -n "$selected" ]; then
    # Extract just the command part (third field) and remove leading tabs in case of multi-line command
    LBUFFER=$(echo "$selected" | tr -d '\t' )
  fi
  zle reset-prompt
  return $ret
}

zle -N custom-history-widget
bindkey '^R' custom-history-widget
