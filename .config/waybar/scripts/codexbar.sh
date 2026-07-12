#!/usr/bin/env bash

set -euo pipefail

readonly AUTH_FILE="$HOME/.pi/agent/auth.json"
readonly CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-codexbar"
readonly CACHE_TTL_SECONDS="${CODEXBAR_CACHE_TTL_SECONDS:-60}"
readonly CLAUDE_CACHE_TTL_SECONDS="${CODEXBAR_CLAUDE_CACHE_TTL_SECONDS:-3600}"
readonly REFRESH_SKEW_SECONDS=300
readonly CLAUDE_RATE_LIMIT_SECONDS="${CODEXBAR_CLAUDE_RATE_LIMIT_SECONDS:-300}"
readonly OPENAI_CLIENT_ID="app_EMoamEEZ73f0CkXaXp7hrann"
readonly CLAUDE_CLIENT_ID="9d1c250a-e61b-44d9-88ed-5944d1962f5e"

function main() {
  command -v curl >/dev/null 2>&1 || fallback "curl missing"
  command -v jq >/dev/null 2>&1 || fallback "jq missing"
  command -v base64 >/dev/null 2>&1 || fallback "base64 missing"

  mkdir -p "$CACHE_DIR"

  local output
  output="$(collect_provider_results)"

  # lobe-icons glyphs (Plane 15, see ~/Source/lobe-icons-font/codepoints.json)
  local claude_glyph openai_glyph openrouter_glyph
  claude_glyph="󴀶"
  openai_glyph="󴃐"
  openrouter_glyph="󴃖"

  jq -c --arg claude_glyph "$claude_glyph" --arg openai_glyph "$openai_glyph" \
    --arg openrouter_glyph "$openrouter_glyph" \
    -f <(jq_filter) <<<"$output"
}

collect_provider_results() {
  local items=()
  items+=("$(provider_result codex fetch_codex_usage)")
  items+=("$(provider_result claude fetch_claude_usage)")

  local or_key
  or_key="$(openrouter_api_key)"
  if [[ -n "$or_key" ]]; then
    items+=("$(OPENROUTER_API_KEY="$or_key" provider_result openrouter fetch_openrouter_usage)")
  fi

  printf '%s\n' "${items[@]}" | jq -cs '.'
}

provider_result() {
  local provider="$1"
  local fetch_fn="$2"
  local cache_file="$CACHE_DIR/$provider.json"
  local error_file result warning fetch_status
  error_file="$(mktemp)"

  if cache_is_fresh "$cache_file" "$provider"; then
    cat "$cache_file"
    rm -f "$error_file"
    return 0
  fi

  result="$($fetch_fn 2>"$error_file")" && fetch_status=0 || fetch_status=$?
  if ((fetch_status == 0)) && jq -e . >/dev/null 2>&1 <<<"$result"; then
    printf '%s\n' "$result" >"$cache_file"
    rm -f "$error_file"
    printf '%s\n' "$result"
    return 0
  fi

  # Silent backoff (exit 2): a rate-limit block is expected and transient, so
  # serve the last-known-good cache with no warning and without refreshing its
  # mtime, letting automatic retries resume once the block expires.
  if ((fetch_status == 2)) && [[ -s "$cache_file" ]]; then
    rm -f "$error_file"
    cat "$cache_file"
    return 0
  fi

  warning="$(tr '\n' ' ' <"$error_file" | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')"
  rm -f "$error_file"
  [[ -n "$warning" ]] || warning="failed to fetch $provider usage"

  if [[ -s "$cache_file" ]]; then
    jq -c --arg warning "stale: $warning" '. + {warning: $warning}' "$cache_file"
    return 0
  fi

  jq -cn --arg provider "$provider" --arg message "$warning" \
    '{provider:$provider, error:{message:$message}}'
}

cache_is_fresh() {
  local file="$1"
  local provider="${2:-}"
  [[ -s "$file" ]] || return 1

  local now mtime ttl
  now="$(date +%s)"
  mtime="$(stat_mtime "$file")"
  ttl="$(provider_cache_ttl_seconds "$provider")"
  ((now - mtime < ttl))
}

provider_cache_ttl_seconds() {
  local provider="$1"
  case "$provider" in
  claude) printf '%s\n' "$CLAUDE_CACHE_TTL_SECONDS" ;;
  *) printf '%s\n' "$CACHE_TTL_SECONDS" ;;
  esac
}

stat_mtime() {
  local file="$1"
  stat -c %Y "$file" 2>/dev/null || stat -f %m "$file"
}

http_get() {
  local url="$1"
  local headers="$2"
  local body="$3"
  local max_time="$4"
  shift 4

  curl -sS -D "$headers" -o "$body" -w '%{http_code}' \
    --connect-timeout 5 --max-time "$max_time" \
    "$@" "$url"
}

update_auth_token() {
  local filter="$1"
  local access="$2"
  local refresh="$3"
  local expires="$4"
  local tmp

  tmp="$(mktemp)"
  jq --arg access "$access" --arg refresh "$refresh" --argjson expires "$expires" \
    "$filter" "$AUTH_FILE" >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$AUTH_FILE"
}

fetch_codex_usage() {
  local access account_id
  read -r access account_id < <(codex_credentials)

  local headers body status
  headers="$(mktemp)"
  body="$(mktemp)"
  status="$(http_get https://chatgpt.com/backend-api/wham/usage "$headers" "$body" 30 \
    -H "Authorization: Bearer $access" \
    -H "ChatGPT-Account-Id: $account_id" \
    -H "User-Agent: CodexBar" \
    -H "Accept: application/json")" || {
    rm -f "$headers" "$body"
    echo "Codex network error" >&2
    return 1
  }

  if [[ "$status" == "401" || "$status" == "403" ]]; then
    rm -f "$headers" "$body"
    refresh_codex_token >/dev/null || return 1
    read -r access account_id < <(codex_credentials false)
    headers="$(mktemp)"
    body="$(mktemp)"
    status="$(http_get https://chatgpt.com/backend-api/wham/usage "$headers" "$body" 30 \
      -H "Authorization: Bearer $access" \
      -H "ChatGPT-Account-Id: $account_id" \
      -H "User-Agent: CodexBar" \
      -H "Accept: application/json")" || {
      rm -f "$headers" "$body"
      echo "Codex network error after refresh" >&2
      return 1
    }
  fi

  if [[ ! "$status" =~ ^2 ]]; then
    local summary
    summary="$(response_summary "$body")"
    rm -f "$headers" "$body"
    echo "Codex API HTTP $status: $summary" >&2
    return 1
  fi

  jq -c -f <(codex_usage_filter) "$body"
  rm -f "$headers" "$body"
}

codex_credentials() {
  local allow_refresh="${1:-true}"
  [[ -f "$AUTH_FILE" ]] || die "missing $AUTH_FILE"

  local raw access refresh expires account_id now
  raw="$(jq -r '[."openai-codex".access // "", ."openai-codex".refresh // "", (."openai-codex".expires // 0 | tostring), ."openai-codex".accountId // ""] | @tsv' "$AUTH_FILE")"
  IFS=$'\t' read -r access refresh expires account_id <<<"$raw"
  now="$(date +%s)"

  [[ -n "$access" ]] || die "missing openai-codex access token"
  [[ -n "$account_id" ]] || die "missing openai-codex accountId"

  if [[ "$allow_refresh" == "true" && -n "$refresh" && "$expires" =~ ^[0-9]+$ ]] &&
    ((now + REFRESH_SKEW_SECONDS >= expires)); then
    refresh_codex_token >/dev/null || return 1
    access="$(jq -r '."openai-codex".access // empty' "$AUTH_FILE")"
    account_id="$(jq -r '."openai-codex".accountId // empty' "$AUTH_FILE")"
  fi

  printf '%s %s\n' "$access" "$account_id"
}

refresh_codex_token() {
  local refresh
  refresh="$(jq -r '."openai-codex".refresh // empty' "$AUTH_FILE")"
  [[ -n "$refresh" ]] || {
    echo "Codex refresh token missing" >&2
    return 1
  }

  local body status request
  body="$(mktemp)"
  request="$(jq -cn --arg client_id "$OPENAI_CLIENT_ID" --arg refresh "$refresh" \
    '{client_id:$client_id, grant_type:"refresh_token", refresh_token:$refresh, scope:"openid profile email"}')"

  status="$(curl -sS -o "$body" -w '%{http_code}' \
    --connect-timeout 5 --max-time 30 \
    -H 'Content-Type: application/json' \
    -d "$request" \
    https://auth.openai.com/oauth/token)" || {
    rm -f "$body"
    echo "Codex token refresh network error" >&2
    return 1
  }

  if [[ ! "$status" =~ ^2 ]]; then
    local summary
    summary="$(response_summary "$body")"
    rm -f "$body"
    echo "Codex token refresh HTTP $status: $summary" >&2
    return 1
  fi

  local access new_refresh expires
  access="$(jq -r '.access_token // empty' "$body")"
  new_refresh="$(jq -r --arg refresh "$refresh" '.refresh_token // $refresh' "$body")"
  expires="$(jwt_exp "$access")"
  [[ -n "$access" ]] || {
    rm -f "$body"
    echo "Codex token refresh returned no access token" >&2
    return 1
  }
  [[ -n "$expires" ]] || expires="$(($(date +%s) + 86400))"

  # shellcheck disable=SC2016
  update_auth_token \
    '."openai-codex".access = $access
     | ."openai-codex".refresh = $refresh
     | ."openai-codex".expires = $expires' \
    "$access" "$new_refresh" "$expires"
  rm -f "$body"
}

claude_empty_usage() {
  printf '%s\n' '{"provider":"claude","usage":{"primary":null,"secondary":null,"extraRateWindows":[]}}'
}

fetch_claude_usage() {
  local blocked_until now
  blocked_until="$(cat "$CACHE_DIR/claude.blocked_until" 2>/dev/null || true)"
  now="$(date +%s)"
  if [[ "$blocked_until" =~ ^[0-9]+$ ]] && ((blocked_until > now)); then
    if [[ -s "$CACHE_DIR/claude.json" ]]; then
      return 2
    fi
    claude_empty_usage
    return 0
  fi

  local access
  access="$(claude_access_token)"

  local headers body status
  headers="$(mktemp)"
  body="$(mktemp)"
  status="$(http_get https://api.anthropic.com/api/oauth/usage "$headers" "$body" 30 \
    -H "Authorization: Bearer $access" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "User-Agent: claude-code/2.1.0")" || {
    rm -f "$headers" "$body"
    echo "Claude OAuth network error" >&2
    return 1
  }

  if [[ "$status" == "401" ]]; then
    rm -f "$headers" "$body"
    refresh_claude_token >/dev/null || return 1
    access="$(claude_access_token false)"
    headers="$(mktemp)"
    body="$(mktemp)"
    status="$(http_get https://api.anthropic.com/api/oauth/usage "$headers" "$body" 30 \
      -H "Authorization: Bearer $access" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "anthropic-beta: oauth-2025-04-20" \
      -H "User-Agent: claude-code/2.1.0")" || {
      rm -f "$headers" "$body"
      echo "Claude OAuth network error after refresh" >&2
      return 1
    }
  fi

  if [[ "$status" == "429" ]]; then
    local until
    until="$(retry_after_epoch "$headers")"
    [[ -n "$until" ]] || until="$((now + CLAUDE_RATE_LIMIT_SECONDS))"
    printf '%s\n' "$until" >"$CACHE_DIR/claude.blocked_until"
    rm -f "$headers" "$body"
    if [[ -s "$CACHE_DIR/claude.json" ]]; then
      return 2
    fi
    claude_empty_usage
    return 0
  fi

  if [[ ! "$status" =~ ^2 ]]; then
    local summary
    summary="$(response_summary "$body")"
    rm -f "$headers" "$body"
    echo "Claude OAuth HTTP $status: $summary" >&2
    return 1
  fi

  rm -f "$CACHE_DIR/claude.blocked_until"
  jq -c -f <(claude_usage_filter) "$body"
  rm -f "$headers" "$body"
}

claude_access_token() {
  local allow_refresh="${1:-true}"
  [[ -f "$AUTH_FILE" ]] || die "missing $AUTH_FILE"

  local raw access refresh expires now
  raw="$(jq -r '[.anthropic.access // "", .anthropic.refresh // "", (.anthropic.expires // 0 | tostring)] | @tsv' "$AUTH_FILE")"
  IFS=$'\t' read -r access refresh expires <<<"$raw"
  now="$(date +%s)"

  [[ -n "$access" ]] || die "missing anthropic access token"

  if [[ "$allow_refresh" == "true" && -n "$refresh" && "$expires" =~ ^[0-9]+$ ]] &&
    ((now + REFRESH_SKEW_SECONDS >= expires)); then
    refresh_claude_token >/dev/null || return 1
    access="$(jq -r '.anthropic.access // empty' "$AUTH_FILE")"
  fi

  printf '%s\n' "$access"
}

refresh_claude_token() {
  local refresh
  refresh="$(jq -r '.anthropic.refresh // empty' "$AUTH_FILE")"
  [[ -n "$refresh" ]] || {
    echo "Claude refresh token missing" >&2
    return 1
  }

  local body status
  body="$(mktemp)"
  status="$(curl -sS -o "$body" -w '%{http_code}' \
    --connect-timeout 5 --max-time 30 \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'Accept: application/json' \
    --data-urlencode 'grant_type=refresh_token' \
    --data-urlencode "refresh_token=$refresh" \
    --data-urlencode "client_id=$CLAUDE_CLIENT_ID" \
    https://platform.claude.com/v1/oauth/token)" || {
    rm -f "$body"
    echo "Claude token refresh network error" >&2
    return 1
  }

  if [[ ! "$status" =~ ^2 ]]; then
    local summary
    summary="$(response_summary "$body")"
    rm -f "$body"
    echo "Claude token refresh HTTP $status: $summary" >&2
    return 1
  fi

  local access new_refresh expires_in expires
  access="$(jq -r '.access_token // empty' "$body")"
  new_refresh="$(jq -r --arg refresh "$refresh" '.refresh_token // $refresh' "$body")"
  expires_in="$(jq -r '.expires_in // 0' "$body")"
  [[ -n "$access" ]] || {
    rm -f "$body"
    echo "Claude token refresh returned no access token" >&2
    return 1
  }
  [[ "$expires_in" =~ ^[0-9]+$ ]] || expires_in=3600
  ((expires_in > 0)) || expires_in=3600
  expires="$(($(date +%s) + expires_in))"

  # shellcheck disable=SC2016
  update_auth_token \
    '.anthropic.access = $access
     | .anthropic.refresh = $refresh
     | .anthropic.expires = $expires' \
    "$access" "$new_refresh" "$expires"
  rm -f "$body"
}

fetch_openrouter_usage() {
  local api_key="${OPENROUTER_API_KEY:-}"
  [[ -n "$api_key" ]] || {
    echo "OpenRouter API key missing" >&2
    return 1
  }

  local base_url="${OPENROUTER_API_URL:-https://openrouter.ai/api/v1}"
  local headers body status
  headers="$(mktemp)"
  body="$(mktemp)"
  status="$(http_get "${base_url%/}/credits" "$headers" "$body" 15 \
    -H "Authorization: Bearer $api_key" \
    -H "Accept: application/json" \
    -H "X-Title: ${OPENROUTER_X_TITLE:-CodexBar}")" || {
    rm -f "$headers" "$body"
    echo "OpenRouter network error" >&2
    return 1
  }

  if [[ ! "$status" =~ ^2 ]]; then
    local summary
    summary="$(response_summary "$body")"
    rm -f "$headers" "$body"
    echo "OpenRouter API HTTP $status: $summary" >&2
    return 1
  fi

  local key_body
  key_body="$(mktemp)"
  timeout 2s curl -sS -o "$key_body" -w '%{http_code}' \
    --connect-timeout 1 --max-time 1 \
    -H "Authorization: Bearer $api_key" \
    -H "Accept: application/json" \
    "${base_url%/}/key" >/dev/null 2>&1 || true

  jq -c -s -f <(openrouter_usage_filter) "$body" "$key_body"
  rm -f "$headers" "$body" "$key_body"
}

openrouter_api_key() {
  local fnox_bin or_key=""
  fnox_bin="$(command -v fnox 2>/dev/null || true)"
  if [[ -z "$fnox_bin" && -x "$HOME/.local/share/mise/shims/fnox" ]]; then
    fnox_bin="$HOME/.local/share/mise/shims/fnox"
  fi
  if [[ -n "$fnox_bin" ]]; then
    or_key="$("$fnox_bin" get OPENROUTER_API_KEY 2>/dev/null || true)"
  fi
  printf '%s\n' "$or_key"
}

jwt_exp() {
  local token="$1"
  local payload b64 pad decoded
  payload="${token#*.}"
  payload="${payload%%.*}"
  [[ -n "$payload" && "$payload" != "$token" ]] || return 0
  b64="$(tr '_-' '/+' <<<"$payload")"
  pad=$(((4 - ${#b64} % 4) % 4))
  while ((pad > 0)); do
    b64="${b64}="
    pad=$((pad - 1))
  done
  decoded="$(printf '%s' "$b64" | base64 -d 2>/dev/null || true)"
  [[ -n "$decoded" ]] || return 0
  jq -r '.exp // empty' <<<"$decoded" 2>/dev/null || true
}

retry_after_epoch() {
  local headers="$1"
  local raw now
  raw="$(awk 'BEGIN{IGNORECASE=1} /^Retry-After:/ {sub(/^[^:]+:[[:space:]]*/, ""); sub(/\r$/, ""); print; exit}' "$headers")"
  [[ -n "$raw" ]] || return 0
  now="$(date +%s)"
  if [[ "$raw" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$((now + raw))"
  else
    date -d "$raw" +%s 2>/dev/null || true
  fi
}

response_summary() {
  local body="$1"
  jq -r '(.error.message // .error // .message // .detail // . | tostring)' "$body" 2>/dev/null |
    tr '\n' ' ' |
    sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//' |
    cut -c1-240
}

date_from_epoch() {
  local epoch="$1"
  date -d "@$epoch" --iso-8601=seconds 2>/dev/null || date -r "$epoch" '+%Y-%m-%dT%H:%M:%S%z'
}

codex_usage_filter() {
  cat <<'JQ'
def ts:
  if . == null then null
  elif type == "number" then todateiso8601
  elif type == "string" and test("^[0-9]+$") then (tonumber | todateiso8601)
  else . end;

def win($w):
  if $w == null then null else {
    usedPercent: (($w.used_percent // $w.usedPercent // 0) | tonumber),
    resetsAt: (($w.reset_at // $w.resets_at // null) | ts),
    windowMinutes: (if ($w.limit_window_seconds // 0) > 0 then (($w.limit_window_seconds / 60) | floor) else null end)
  } end;

def slug:
  ascii_downcase | gsub("[^a-z0-9]+"; "-") | gsub("^-|-$"; "");

{
  provider: "codex",
  usage: {
    primary: win(.rate_limit.primary_window),
    secondary: win(.rate_limit.secondary_window),
    extraRateWindows: [
      (.additional_rate_limits // [])[] as $limit |
      ($limit.limit_name // $limit.metered_feature // "Codex extra limit") as $title |
      ($limit.rate_limit.primary_window // $limit.rate_limit.secondary_window // null) as $window |
      select($window != null) |
      {id: ("codex-" + ($title | slug)), title: $title, window: win($window)}
    ]
  },
  credits: (if .credits then {remaining: ((.credits.balance // 0) | tonumber)} else null end)
}
JQ
}

claude_usage_filter() {
  cat <<'JQ'
def win($w; $minutes):
  if $w == null or $w.utilization == null then null else {
    usedPercent: ($w.utilization | tonumber),
    resetsAt: ($w.resets_at // null),
    windowMinutes: $minutes
  } end;

def primary:
  win(.five_hour; 300)
  // win(.seven_day; 10080)
  // win(.seven_day_oauth_apps; 10080)
  // win(.seven_day_sonnet; 10080)
  // win(.seven_day_opus; 10080);

{
  provider: "claude",
  usage: {
    primary: primary,
    secondary: win(.seven_day; 10080),
    extraRateWindows: ([
      {id:"claude-sonnet", title:"Claude Sonnet Weekly", window: win(.seven_day_sonnet; 10080)},
      {id:"claude-opus", title:"Claude Opus Weekly", window: win(.seven_day_opus; 10080)},
      {id:"claude-routines", title:"Daily Routines", window: (win(.seven_day_routines; 10080) // win(.seven_day_claude_routines; 10080) // win(.claude_routines; 10080) // win(.routines; 10080) // win(.routine; 10080) // win(.seven_day_cowork; 10080) // win(.cowork; 10080))}
    ] | map(select(.window != null)))
  }
}
JQ
}

openrouter_usage_filter() {
  cat <<'JQ'
.[0].data as $credits |
(.[1].data // {}) as $key |
($credits.total_credits // 0) as $totalCredits |
($credits.total_usage // 0) as $totalUsage |
{
  provider: "openrouter",
  usage: {
    openRouterUsage: {
      totalCredits: $totalCredits,
      totalUsage: $totalUsage,
      balance: (($totalCredits - $totalUsage) | if . < 0 then 0 else . end),
      usedPercent: (if $totalCredits > 0 then ([100, (($totalUsage / $totalCredits) * 100)] | min) else 0 end),
      keyDataFetched: (.[1].data != null),
      keyLimit: $key.limit,
      keyUsage: $key.usage,
      keyUsageDaily: $key.usage_daily,
      keyUsageWeekly: $key.usage_weekly,
      keyUsageMonthly: $key.usage_monthly,
      rateLimit: $key.rate_limit
    }
  }
}
JQ
}

jq_filter() {
  cat <<'JQ'
def reset_epoch:
  if type == "number" then .
  elif type == "string" then (gsub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | try fromdateiso8601 catch null)
  else null end;

# Usage percent for a window, or null when the window is missing or has already
# passed its reset (a stale cached value would otherwise be shown as live).
def win_pct($w):
  if $w == null or $w.usedPercent == null then null
  else (($w.resetsAt // null) | reset_epoch) as $reset |
    if $reset != null and $reset <= now then null else $w.usedPercent end
  end;

def pct:
  if .provider == "openrouter" then (.usage.openRouterUsage.usedPercent // 0)
  else [(win_pct(.usage.primary) // 0), (win_pct(.usage.secondary) // 0)] | max end;

def n:
  if type == "number" then (.*100|round/100|tostring) else "?" end;

def duration:
  . as $seconds |
  ($seconds / 3600 | floor) as $hours |
  (($seconds % 3600) / 60 | floor) as $minutes |
  ($hours | tostring) + ":" + (($minutes | tostring) | if length == 1 then "0" + . else . end);

def reset_text($value):
  ($value | reset_epoch) as $epoch |
  if $epoch == null then ($value | tostring)
  else ($epoch | strflocaltime("%d/%m %H:%M")) as $absolute |
    (($epoch - now) | floor) as $seconds |
    (if $seconds <= 0 then "now" else "in " + ($seconds | duration) end) + " (" + $absolute + ")"
  end;

def title:
  if .provider == "codex" then "Codex"
  elif .provider == "claude" then "Claude"
  elif .provider == "openrouter" then "OpenRouter"
  else (.provider // "unknown") end;

def badge:
  if .provider == "codex" then $openai_glyph
  elif .provider == "claude" then $claude_glyph
  elif .provider == "openrouter" then $openrouter_glyph
  else (.provider[0:2] | ascii_upcase) end;

def paint($text; $p):
  if $p >= 90 then "<span foreground=\"#f7768e\">" + $text + "</span>"
  elif $p >= 60 then "<span foreground=\"#e0af68\">" + $text + "</span>"
  else $text end;

def short:
  if .error then paint(badge + "-"; 100)
  elif .provider == "codex" or .provider == "claude" then
    win_pct(.usage.primary) as $primary |
    win_pct(.usage.secondary) as $weekly |
    ([($primary // 0), ($weekly // 0)] | max) as $p |
    paint(badge + "" + ($primary|n) + "%|" + ($weekly|n) + "%"; $p)
  elif .provider == "openrouter" then
    (.usage.openRouterUsage.balance // 0) as $bal |
    (.usage.openRouterUsage.usedPercent // 0) as $p |
    paint(badge + "$" + (($bal*100|round/100)|tostring); $p)
  else empty end;

def window($name; $w):
  if $w == null or $w.usedPercent == null then empty else
    $name + ": " + (win_pct($w)|n) + "%"
    + (if $w.resetsAt then " · resets " + reset_text($w.resetsAt)
       elif $w.resetDescription then " · resets " + $w.resetDescription else "" end)
  end;

def extra_windows:
  [(.usage.extraRateWindows // [])[] |
    select((.window.usedPercent // 0) > 0 or .window.resetDescription or .window.resetsAt) |
    (.title // .id // "Extra") + ": "
    + (win_pct(.window)|n) + "%"
    + (if .window.resetsAt then " · resets " + reset_text(.window.resetsAt)
       elif .window.resetDescription then " · resets " + .window.resetDescription else "" end)][];

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
    (if .warning then .warning else empty end),
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

Print Claude, Codex, and OpenRouter usage as Waybar JSON without CodexBar.
EOF
}

die() {
  echo "Error: $1" >&2
  exit "${2:-1}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi
  main "$@"
fi
