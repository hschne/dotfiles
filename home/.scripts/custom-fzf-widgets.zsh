
# Function to format atuin output with relative timestamps
custom-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null

  local dir_key="ctrl-d"
  local session_key="ctrl-s" 
  local all_key="ctrl-a"
  
  local header="History | ${dir_key}: Directory | ${session_key}: Session | ${all_key}: All"
  local ATUIN_COMMAND="atuin history list --format '{relativetime}\t{duration}\t{command}' --print0" 
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
    --accept-nth=3 \
    --query=${LBUFFER} +m
  )
  
  local ret=$?
  if [ -n "$selected" ]; then
    # Extract just the command part (third field)
    LBUFFER=$(echo "$selected")
  fi
  zle reset-prompt
  return $ret
}

zle -N custom-history-widget
bindkey '^R' custom-history-widget

# custom-history-widget() {
#   local selected
#   setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
#   local awk_filter='{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }'
#   if [[ -o extended_history ]]; then
#     awk_filter='
#       {
#         ts = int($2)
#         delta = systime() - ts
#         cmd_id = $1
#
#         gray="\033[38;5;60m"
#         reset="\033[0m"
#
#         # Format the timestamp with appropriate unit (left-aligned with padding after)
#         if (delta < 60) { 
#           time_str = sprintf("%4s ", delta "s")
#         } else if (delta < 3600) { 
#           time_str = sprintf("%4s ", int(delta/60) "m")
#         } else if (delta < 86400) { 
#           time_str = sprintf("%4s ", int(delta/3600) "h")
#         } else if (delta < 604800) { 
#           time_str = sprintf("%4s ", int(delta/86400) "d")
#         } else if (delta < 2592000) { 
#           time_str = sprintf("%4s ", int(delta/604800) "w")
#         } else if (delta < 31536000) { 
#           time_str = sprintf("%4s ", int(delta/2592000) "M")
#         } else { 
#           time_str = sprintf("%4s ", int(delta/31536000) "y")
#         }
#
#         # Lots of padding to align with color codes
#         cmd_id_padded = sprintf("%5s", cmd_id)
#         cmd_id_colored = sprintf("%-18s", gray cmd_id_padded reset)
#         $1 = cmd_id_colored
#         time_str_colored = sprintf("%-18s", gray time_str reset)
#         $2 = time_str_colored
#
#         # Save original line and process for deduplication
#         line = $0
#         $1 = ""; $2 = ""
#         if (!seen[$0]++) print line
#       }'
#     fc_opts='-i'
#     n=2
#   fi
#   selected="$(fc -rl $fc_opts -t '%s' 1 | awk "$awk_filter" |
#     FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n3.. --with-nth 1.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m") \
#     FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
#
#   local ret=$?
#   if [ -n "$selected" ]; then
#     if [[ $(awk '{print $1; exit}' <<< "$selected") =~ ^[1-9][0-9]* ]]; then
#       zle vi-fetch-history -n $MATCH
#     else # selected is a custom query, not from history
#       LBUFFER="$selected"
#     fi
#   fi
#   zle reset-prompt
#   return $ret
# }
# zle -N custom-history-widget
# bindkey '^R' custom-history-widget
