#!/bin/sh
# tinted-theming: apply-extras must write through a stowed symlink, not replace it,
# and give Claude Code a theme and status line colours that follow the scheme.
d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT
schemes=$d/data/tinted-theming/tinty/repos/schemes/base16
mkdir -p "$d/repo" "$d/config/workmux" "$d/config/omniwm/shell/themes" "$d/claude" "$schemes"
echo 'theme: default' >"$d/repo/config.yaml"
ln -s "$d/repo/config.yaml" "$d/config/workmux/config.yaml"
echo '# placeholder' >"$d/repo/tinty.toml"
ln -s "$d/repo/tinty.toml" "$d/config/omniwm/shell/themes/tinty.toml"
palette='palette:
  base00: "#000000"
  base01: "#010101"
  base02: "#020202"
  base03: "#030303"
  base04: "#040404"
  base05: "#050505"
  base06: "#060606"
  base07: "#070707"
  base08: "#ff0000"
  base09: "#ff8000"
  base0A: "#ffff00"
  base0B: "#00ff00"
  base0C: "#00ffff"
  base0D: "#0000ff"
  base0E: "#ff00ff"
  base0F: "#800000"'
printf 'variant: "light"\n%s\n' "$palette" >"$schemes/t.yaml"
printf 'variant: "dark"\n%s\n' "$palette" >"$schemes/u.yaml"
apply() {
  HOME=$d XDG_CONFIG_HOME=$d/config XDG_DATA_HOME=$d/data CLAUDE_CONFIG_DIR=$d/claude \
    ruby "$1/.config/tinted-theming/tinty/hooks/apply-extras.rb" "$2" >/dev/null 2>&1
}
apply "$1" base16-t
[ -L "$d/config/workmux/config.yaml" ] || { echo "workmux config.yaml symlink was replaced"; exit 1; }
grep -q 'accent: "#0000ff"' "$d/repo/config.yaml" || { echo "workmux colours not written through"; exit 1; }
[ -L "$d/config/omniwm/shell/themes/tinty.toml" ] || { echo "OmniShell tinty.toml symlink was replaced"; exit 1; }
grep -q '^accent = "#0000ff"$' "$d/repo/tinty.toml" || { echo "OmniShell theme not written through"; exit 1; }
[ "$(grep -c '^background = "#000000"$' "$d/repo/tinty.toml")" -eq 2 ] || { echo "OmniShell theme lacks a [light] or [dark] palette"; exit 1; }

grep -q '"base": "light-ansi"' "$d/claude/themes/tinty.json" || { echo "light scheme did not get light-ansi"; exit 1; }
# every colour the status line asks for is set, and in the form its pill() expects
vars=$(grep -oE '\$\{?[FB]G_[A-Z_]+' "$1/.claude/statusline-command.sh" | tr -d '${' | sort -u)
[ -n "$vars" ] || { echo "found no colour variables in statusline-command.sh"; exit 1; }
for v in $vars; do
  grep -qE "^$v=\"[34]8;2;[0-9]+;[0-9]+;[0-9]+\"$" "$d/claude/statusline-colors.env" || { echo "statusline-colors.env lacks $v"; exit 1; }
done
grep -q '^BG_MODEL="48;2;0;0;255"$' "$d/claude/statusline-colors.env" || { echo "status line colours do not match the scheme"; exit 1; }
apply "$1" base16-u
grep -q '"base": "dark-ansi"' "$d/claude/themes/tinty.json" || { echo "dark scheme did not get dark-ansi"; exit 1; }
