#!/bin/sh
# Push the current workspace's layout (niri / dwindle) into the OmniShell
# `layout` widget. Run by `omniwmctl watch layout-changed,active-workspace
# --reconnect --exec <this>` (LaunchAgent local.omnishell.layout). Always sends:
# widget state resets when OmniShell reloads.
ctl=/opt/homebrew/bin/omniwmctl

layout=$("$ctl" query workspaces --current --fields layout --format json 2>/dev/null |
	sed -n 's/.*"layout" *: *"\([a-z]*\)".*/\1/p' | head -1)
[ -n "$layout" ] || exit 0
exec "$ctl" shell trigger layout layout "$layout" >/dev/null 2>&1
