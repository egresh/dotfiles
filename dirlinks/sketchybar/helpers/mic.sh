#!/usr/bin/env bash
# mic.sh — query or toggle the mute state of the default audio input device.
#
#   mic.sh          -> prints "muted", "active", or "n/a"
#   mic.sh toggle   -> flips the state, then prints the new one
#
# macOS has no scriptable "input muted" flag (only output has one), so "muted"
# is modelled as input volume 0. The pre-mute level is stashed so unmuting
# restores it; falls back to 75 when there's nothing sensible to restore.
set -euo pipefail

STORE="${TMPDIR:-/tmp}/sketchybar_mic_level"

read_vol() { /usr/bin/osascript -e 'input volume of (get volume settings)' 2>/dev/null; }
set_vol()  { /usr/bin/osascript -e "set volume input volume $1" >/dev/null 2>&1 || true; }

vol="$(read_vol)"
case "${vol:-}" in
  ''|*[!0-9]*) echo "n/a"; exit 0 ;;   # no input device / "missing value"
esac

if [ "${1:-}" = "toggle" ]; then
  if [ "$vol" -eq 0 ]; then
    restore="$(cat "$STORE" 2>/dev/null || echo 75)"
    case "$restore" in ''|*[!0-9]*|0) restore=75 ;; esac
    set_vol "$restore"
    vol="$restore"
  else
    printf '%s' "$vol" > "$STORE" 2>/dev/null || true
    set_vol 0
    vol=0
  fi
fi

[ "$vol" -eq 0 ] && echo "muted" || echo "active"
