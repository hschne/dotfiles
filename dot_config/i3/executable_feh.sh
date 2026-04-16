#!/usr/bin/env bash

file=$(find ~/Pictures/Backgrounds | shuf -n 1)
feh --bg-fill "$file"

