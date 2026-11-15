#!/usr/bin/env bash

# Usage:
#   In your tmux.conf, put this:
#   bind-key <key> run-shell '<path-to-this-script> <id>'
#
#   Example: 'bind-key -n M-r run-shell "~/.config/tmux/toggle-pane.sh r"'
#
#   The argument '<id>' is used to enable multiple toggable panes.

SESSION="_hide"
PBID="_P${1:-buf}"
LBID="_L${1:-buf}"

get_pid() {
	local res
	res="$(tmux showb -b "$PBID")"
	echo "${res:-empty}"
}

get_layout() {
	local res
	res="$(tmux showb -b "$LBID")"
	echo "${res:-empty}"
}

pane_visible() { [ -n "$(tmux lsp -F '#{pane_id}' | awk "/$(get_pid)/")" ]; }

pane_exists() { [ -n "$(tmux lsp -a -F '#{pane_id}' | awk "/$(get_pid)/")" ]; }

break_pane() {
	tmux breakp -d -s "$(get_pid)" -t "$SESSION" -n "$(get_pid)"
	tmux select-layout "$(get_layout)"
}

create_pane() {
	tmux setb -b "$LBID" "$(tmux display -p '#{window_layout}')"
	tmux setb -b "$PBID" "$(tmux split-window -P -F '#{pane_id}')"
}

restore_pane() {
	tmux setb -b "$LBID" "$(tmux display -p '#{window_layout}')"
	tmux joinp -s "$(get_pid)"
}

main() {
	if pane_visible; then
		tmux new -d -s "$SESSION"
		break_pane
	else
		if pane_exists; then
			restore_pane
		else
			create_pane
		fi
	fi
}

main "$@"
