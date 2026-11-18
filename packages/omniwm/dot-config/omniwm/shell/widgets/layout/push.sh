#!/bin/sh
# Push the current workspace's layout (niri / dwindle) and whether the focused
# window floats into the OmniShell `layout` widget. Run by `omniwmctl watch
# focus,windows-changed,layout-changed,active-workspace --reconnect --exec
# <this>` (LaunchAgent local.omnishell.layout); toggling a window's floating
# fires windows-changed and layout-changed. Always sends: widget state resets
# when OmniShell reloads.
ctl=/opt/homebrew/bin/omniwmctl

if "$ctl" query windows --focused --fields mode --format json 2>/dev/null |
	grep -q '"mode" *: *"floating"'; then
	floating=true
else
	floating=false
fi
"$ctl" shell trigger layout floating "$floating" >/dev/null 2>&1

layout=$("$ctl" query workspaces --current --fields layout --format json 2>/dev/null |
	sed -n 's/.*"layout" *: *"\([a-z]*\)".*/\1/p' | head -1)
[ -n "$layout" ] || exit 0
exec "$ctl" shell trigger layout layout "$layout" >/dev/null 2>&1
