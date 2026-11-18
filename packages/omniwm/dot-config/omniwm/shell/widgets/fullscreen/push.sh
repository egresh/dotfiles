#!/bin/sh
# Push the focused window's fullscreen state into the OmniShell `fullscreen`
# widget. Run by `omniwmctl watch focus,windows-changed,layout-changed
# --reconnect --exec <this>` (LaunchAgent local.omnishell.fullscreen) and by the
# toggle.sh (Karabiner leader-f) after toggle-fullscreen. Always sends (no change
# cache): widget state resets when OmniShell reloads, so a skipped send could
# leave it stale.
#
# Events can arrive before OmniWM's fullscreen flag settles (e.g. focusing a
# fullscreen window reported false), so check again after short delays and
# push whatever comes back.
ctl=/opt/homebrew/bin/omniwmctl

push() {
	if "$ctl" query windows --focused --fields is-fullscreen --format json 2>/dev/null |
		grep -q '"isFullscreen" *: *true'; then
		fs=true
	else
		fs=false
	fi
	"$ctl" shell trigger fullscreen fullscreen "$fs" >/dev/null 2>&1
}

push
sleep 0.3
push
sleep 0.7
push
