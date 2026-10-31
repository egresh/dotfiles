#!/usr/bin/env bash
#
# Print a representative accent color for an application's icon as a sketchybar
# color literal (0xFFRRGGBB), or "none" when no sufficiently vivid color can be
# sampled (grayscale / monochrome icons). Results — including "none" — are
# cached under helpers/app_colors/ (gitignored); delete that directory to
# re-sample.
#
# Used by wm/omniwm/workspaces.lua to tint the workspace-bar app glyphs to
# roughly match each app's real icon.
#
# Usage: app_color.sh <bundle-id> [app-name]
#
# Pipeline: mdfind resolves the bundle id to an .app, sips renders its .icns to
# PNG (ImageMagick has no ICNS delegate), ImageMagick quantizes and we pick the
# highest-count color that isn't near-black, near-white, or near-gray.

set -euo pipefail

key="${1:-}"
name="${2:-}"
[ -n "$key" ] || { printf 'none'; exit 0; }

here="$(cd "$(dirname "$0")" && pwd)"
cache_dir="$here/app_colors"
mkdir -p "$cache_dir"
cache="$cache_dir/$(printf '%s' "$key" | tr -c 'A-Za-z0-9._-' '_')"
[ -f "$cache" ] && { cat "$cache"; exit 0; }

MAGICK="${MAGICK:-/opt/homebrew/bin/magick}"
[ -x "$MAGICK" ] || MAGICK="$(command -v magick || true)"

resolve() {
	local p
	p="$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == '$key'" 2>/dev/null | /usr/bin/head -1)"
	if [ -z "$p" ] && [ -n "$name" ]; then
		p="$(/usr/bin/mdfind \
			"kMDItemContentType == 'com.apple.application-bundle' && kMDItemDisplayName == '$name'" \
			2>/dev/null | /usr/bin/head -1)"
	fi
	printf '%s' "$p"
}

color="none"
app="$(resolve)"
if [ -n "$app" ] && [ -d "$app" ] && [ -n "$MAGICK" ]; then
	icns="$(/usr/bin/find "$app/Contents/Resources" -maxdepth 1 -name '*.icns' 2>/dev/null | /usr/bin/head -1)"
	if [ -n "${icns:-}" ] && [ -f "$icns" ]; then
		tmp="$(/usr/bin/mktemp -t appcolor).png"
		if /usr/bin/sips -s format png "$icns" --out "$tmp" --resampleWidth 256 >/dev/null 2>&1; then
			hex="$("$MAGICK" "$tmp" -trim +repage -alpha remove -alpha off \
				-resize 64x64 -colors 12 -depth 8 -format '%c' histogram:info: 2>/dev/null |
				/usr/bin/sed -E 's/^[[:space:]]*([0-9]+):[[:space:]]*\(([0-9]+),([0-9]+),([0-9]+)\).*/\1 \2 \3 \4/' |
				/usr/bin/awk '{
					n=$1; r=$2; g=$3; b=$4
					mx=r; if(g>mx)mx=g; if(b>mx)mx=b
					mn=r; if(g<mn)mn=g; if(b<mn)mn=b
					sat=(mx==0)?0:(mx-mn)/mx
					if (mx<30 || mn>225 || sat<0.20) next
					printf "%d %02X%02X%02X\n", n, r, g, b
				}' |
				/usr/bin/sort -rn | /usr/bin/head -1 | /usr/bin/awk '{print $2}')"
			[ -n "$hex" ] && color="0xFF$hex"
		fi
		rm -f "$tmp"
	fi
fi

printf '%s' "$color" | /usr/bin/tee "$cache"
