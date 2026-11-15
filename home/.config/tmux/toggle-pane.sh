#!/usr/bin/env bash

# Usage:
#   In your tmux.conf, put this:
#   bind-key <key> run-shell '<path-to-this-script> <id>'
#
#   Example: 'bind-key -n M-r run-shell "~/.config/tmux/toggle-pane.sh r"'
#
#   The argument '<id>' is used to enable multiple toggable panes.

SESSION="_hide"
PBID="_P${1:-r}"
LBID="_L${1:-r}"

PID="$(tmux show -gqv "@$PBID")"
PID="${PID:-empty}"
LAYOUT="$(tmux show -gqv "@$LBID")"

pane_visible() { [ -n "$(tmux lsp -F '#{pane_id}' | awk "/$PID/")" ]; }

pane_exists() { [ -n "$(tmux lsp -a -F '#{pane_id}' | awk "/$PID/")" ]; }

session_doesnt_exist() {
	[ -z "$(tmux list-session -f "#{==:$SESSION,#{session_name}}")" ]
}

break_pane() {
	tmux breakp -d -s "$PID" -t "$SESSION:" -n "$PID" \; \
		select-layout "$LAYOUT"
}

create_pane() {
	tmux set -g "@$LBID" "$(tmux display -p '#{window_layout}')" \; \
		set -g "@$PBID" "$(tmux split-window -P -F '#{pane_id}')"
}

restore_pane() {
	tmux set -g "@$LBID" "$(tmux display -p '#{window_layout}')" \; \
		joinp -s "$PID"
}

main() {
	if pane_visible; then
		if session_doesnt_exist; then
			tmux new -d -s "$SESSION"
		fi
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
