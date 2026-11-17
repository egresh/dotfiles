#!/bin/sh
# tinted-theming: apply-extras must write through a stowed symlink, not replace it
# (workmux config, OmniShell theme).
d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT
schemes=$d/data/tinted-theming/tinty/repos/schemes/base16
mkdir -p "$d/repo" "$d/config/workmux" "$d/config/omniwm/shell/themes" "$schemes"
echo 'theme: default' >"$d/repo/config.yaml"
ln -s "$d/repo/config.yaml" "$d/config/workmux/config.yaml"
echo '# placeholder' >"$d/repo/tinty.toml"
ln -s "$d/repo/tinty.toml" "$d/config/omniwm/shell/themes/tinty.toml"
cat >"$schemes/t.yaml" <<'YAML'
palette:
  base00: "#000000"
  base01: "#010101"
  base02: "#020202"
  base03: "#030303"
  base04: "#040404"
  base05: "#050505"
  base08: "#ff0000"
  base09: "#ff8000"
  base0A: "#ffff00"
  base0B: "#00ff00"
  base0C: "#00ffff"
  base0D: "#0000ff"
  base0E: "#ff00ff"
  base0F: "#800000"
YAML
HOME=$d XDG_CONFIG_HOME=$d/config XDG_DATA_HOME=$d/data \
  ruby "$1/.config/tinted-theming/tinty/hooks/apply-extras.rb" base16-t >/dev/null 2>&1
[ -L "$d/config/workmux/config.yaml" ] || { echo "workmux config.yaml symlink was replaced"; exit 1; }
grep -q 'accent: "#0000ff"' "$d/repo/config.yaml" || { echo "workmux colours not written through"; exit 1; }
[ -L "$d/config/omniwm/shell/themes/tinty.toml" ] || { echo "OmniShell tinty.toml symlink was replaced"; exit 1; }
grep -q '^accent = "#0000ff"$' "$d/repo/tinty.toml" || { echo "OmniShell theme not written through"; exit 1; }
[ "$(grep -c '^background = "#000000"$' "$d/repo/tinty.toml")" -eq 2 ] || { echo "OmniShell theme lacks a [light] or [dark] palette"; exit 1; }
