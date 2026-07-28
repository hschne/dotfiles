#!/usr/bin/env bash
# Desktop notification hook for Claude Code.
#
# Sends a native notification via notify-send when Claude finishes a turn or
# needs input. Port of ~/.pi/agent/extensions/notify.ts, which does the same
# thing off pi's agent_end event.
#
# Usage (wired up in ~/.claude/settings.json):
#   notify.sh stop          # Stop hook — turn finished
#   notify.sh notification  # Notification hook — permission prompt / idle
#
# Hook input arrives as JSON on stdin.

set -uo pipefail

MODE="${1:-stop}"
MAX_BODY=200

command -v notify-send >/dev/null 2>&1 || exit 0

payload="$(cat)"
transcript="$(jq -r '.transcript_path // empty' <<<"$payload")"
cwd="$(jq -r '.cwd // empty' <<<"$payload")"

# Title carries the project so parallel checkouts are distinguishable.
title="Claude Code"
[[ -n $cwd ]] && title="Claude Code — $(basename "$cwd")"

# Flatten markdown to something that reads sanely in a notification bubble.
simplify() {
  sed -e '/^[[:space:]]*```/d' \
      -e 's/^#\{1,6\}[[:space:]]*//' \
      -e 's/^[[:space:]]*[-*+][[:space:]]\+/• /' \
      -e 's/\[\([^]]*\)\]([^)]*)/\1/g' \
      -e 's/\*\*//g' -e 's/\*\([^*]\{1,\}\)\*/\1/g' -e 's/`//g' |
    tr '\n' ' ' |
    tr -s '[:space:]' ' ' |
    sed -e 's/^ //' -e 's/ $//'
}

truncate_body() {
  local text
  text="$(cat)"
  if (( ${#text} > MAX_BODY )); then
    printf '%s…' "${text:0:MAX_BODY-1}"
  else
    printf '%s' "$text"
  fi
}

case "$MODE" in
  notification)
    body="$(jq -r '.message // "Waiting for your input"' <<<"$payload" | simplify | truncate_body)"
    notify-send -t 60000 -u normal "$title" "${body:-Waiting for your input}"
    ;;
  stop)
    body=""
    if [[ -n $transcript && -f $transcript ]]; then
      # Last text block from the main agent. isSidechain lines are subagents —
      # the pi extension stayed silent for those too.
      body="$(jq -rs '
        [ .[]
          | select(.type == "assistant" and (.isSidechain != true))
          | .message.content[]?
          | select(.type == "text")
          | .text
        ] | last // ""
      ' "$transcript" 2>/dev/null | simplify | truncate_body)"
    fi
    notify-send -t 60000 -u low "$title" "${body:-Task completed}"
    ;;
  *)
    exit 0
    ;;
esac
