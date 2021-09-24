#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

DEFAULT_NETWORK_INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

MONITOR1="$(xrandr --listmonitors | grep "0:" | cut -d ' ' -f6)"
MONITOR2="$(xrandr --listmonitors | grep "1:" | cut -d ' ' -f6)"

if [[ -n "$MONITOR1" ]]; then
    MONITOR="$MONITOR1" polybar primary &
fi

if [[ -n "$MONITOR2" ]]; then
    MONITOR="$MONITOR2" polybar secondary &
fi
