#!/bin/sh
# Toggle the focused window's fullscreen (Karabiner leader-f, :omnifs).
#
# toggle-fullscreen doesn't raise the window, and neither does OmniWM's
# directional focus, so a fullscreen window can come up underneath windows that
# were raised later. In niri the columns to its right stay in view under it and
# cover it. Re-focusing the focused window by id raises it.
#
# toggle-fullscreen emits no OmniWM event either, so finish by pushing the new
# state to the OmniShell fullscreen widget (push.sh, next to this file).
ctl=/opt/homebrew/bin/omniwmctl

"$ctl" command toggle-fullscreen >/dev/null 2>&1
id=$("$ctl" query windows --focused --fields id --format json 2>/dev/null |
	sed -n 's/.*"id" *: *"\(ow_[^"]*\)".*/\1/p' | head -1)
[ -n "$id" ] && "$ctl" window focus "$id" >/dev/null 2>&1
exec "$(dirname "$0")/push.sh"
