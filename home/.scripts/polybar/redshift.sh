#!/usr/bin/env bash

# Configure redshift widget for Polybar
main() {
	local mode="$1"

	case $mode in
	toggle)
		toggleRedshift
		;;
	increase)
		changeTemperature +300
		;;
	decrease)
		changeTemperature -300
		;;
	temperature)
		if isRunning; then
			currentTemperature
		else
			echo off
		fi
		;;
	esac

}

isRunning() {
	systemctl --user is-active redshift &>/dev/null
	return $?
}

toggleRedshift() {
	if isRunning; then
		systemctl --user stop redshift
	else
		systemctl --user start redshift
	fi
}

currentTemperature() {
	redshift -p 2>/dev/null | grep "Color temperature" | sed 's/.*: //'
}

changeTemperature() {
	local current=$(currentTemperature | tr -d K)
	local change=$1
	local target=$((current + change))

	if [ "$target" -gt 1000 ] && [ "$target" -lt 9000 ]; then
		redshift -P -O $target
	fi
}

main "$@"
