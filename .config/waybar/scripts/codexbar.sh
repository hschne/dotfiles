#!/usr/bin/env bash

set -euo pipefail

function main() {
  command -v codexbar >/dev/null 2>&1 || fallback "codexbar missing"
  command -v jq >/dev/null 2>&1 || fallback "jq missing"

  local output
  local error_file
  error_file="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm -f '$error_file'" EXIT

  if ! output="$(codexbar usage --provider both --source oauth --format json --json-only 2>"$error_file")"; then
    if [[ -z "$output" ]]; then
      fallback "$(tr '\n' ' ' <"$error_file")"
    fi
  fi

  if [[ -z "$output" ]]; then
    fallback "empty codexbar output"
  fi

  jq -c -f <(jq_filter) <<<"$output"
}

jq_filter() {
  cat <<'JQ'
def pct:
  .usage.primary.usedPercent // .usage.openRouterUsage.usedPercent // 0;

def n:
  if type == "number" then (.*100|round/100|tostring) else "?" end;

def title:
  if .provider == "codex" then "Codex"
  elif .provider == "claude" then "Claude"
  elif .provider == "openrouter" then "OpenRouter"
  else (.provider // "unknown") end;

def badge:
  if .provider == "codex" then "C"
  elif .provider == "claude" then "A"
  else (.provider[0:2] | ascii_upcase) end;

def paint($text; $p):
  if $p >= 90 then "<span foreground=\"#f7768e\">" + $text + "</span>"
  elif $p >= 60 then "<span foreground=\"#e0af68\">" + $text + "</span>"
  else $text end;

def short:
  if .error then paint((.provider[0:1] | ascii_upcase) + "!"; 100)
  elif .provider == "codex" or .provider == "claude" then
    (.usage.primary.usedPercent // 0) as $p |
    paint(badge + ($p|tostring) + "%"; $p)
  else empty end;

def window($name; $w):
  if $w == null or $w.usedPercent == null then empty else
    $name + ": " + (($w.usedPercent // 0)|tostring) + "%"
    + (if $w.resetDescription then " · resets " + $w.resetDescription
       elif $w.resetsAt then " · resets " + $w.resetsAt else "" end)
  end;

def extra_windows:
  [(.usage.extraRateWindows // [])[] |
    select((.window.usedPercent // 0) > 0 or .window.resetDescription or .window.resetsAt) |
    (.title // .id // "Extra") + ": "
    + ((.window.usedPercent // 0)|tostring) + "%"
    + (if .window.resetDescription then " · resets " + .window.resetDescription
       elif .window.resetsAt then " · resets " + .window.resetsAt else "" end)][];

def openrouter_lines:
  .usage.openRouterUsage as $or |
  if $or == null then empty else
    "Balance: $" + (($or.balance // 0)|n),
    "Usage: " + (($or.usedPercent // 0)|n) + "% ($" + (($or.totalUsage // 0)|n) + " / $" + (($or.totalCredits // 0)|n) + ")",
    "Daily: $" + (($or.keyUsageDaily // 0)|n),
    "Weekly: $" + (($or.keyUsageWeekly // 0)|n),
    "Monthly: $" + (($or.keyUsageMonthly // 0)|n)
  end;

def balance_lines:
  if .provider == "openrouter" then openrouter_lines
  elif .credits and (.credits.remaining != null) then
    "Credits: $" + ((.credits.remaining // 0)|n)
  else empty end;

def detail_lines:
  [
    window("Primary"; .usage.primary),
    window("Weekly"; .usage.secondary),
    window("Monthly"; .usage.tertiary),
    extra_windows,
    balance_lines
  ];

def tip:
  if .error then
    title + " ERROR\n" + (.error.message // "unknown error")
  else
    (detail_lines | map(select(length > 0))) as $lines |
    if ($lines | length) == 0 then empty
    else ([title] + $lines) | join("\n") end
  end;

. as $items |
($items | map(pct) | max // 0) as $max |
{
  text: ($items | map(short) | join(" ")),
  tooltip: ($items | map(tip) | map(select(length > 0)) | join("\n\n")),
  percentage: $max,
  class: "normal"
}
JQ
}

fallback() {
  local message="$1"
  jq -cn --arg message "$message" \
    '{text:"?", tooltip:$message, class:"critical", percentage:0}'
  exit 0
}

usage() {
  cat <<EOF
Usage: $(basename "$0")

Print CodexBar usage as Waybar JSON.
EOF
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi
  main "$@"
fi
