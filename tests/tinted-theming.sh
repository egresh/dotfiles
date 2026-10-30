#!/bin/sh
# tinted-theming: apply-extras must write through a stowed symlink, not replace it.
d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT
schemes=$d/data/tinted-theming/tinty/repos/schemes/base16
mkdir -p "$d/repo" "$d/config/workmux" "$schemes"
echo 'theme: default' >"$d/repo/config.yaml"
ln -s "$d/repo/config.yaml" "$d/config/workmux/config.yaml"
cat >"$schemes/t.yaml" <<'YAML'
palette:
  base08: "#ff0000"
  base0A: "#ffff00"
  base0B: "#00ff00"
  base0D: "#0000ff"
YAML
XDG_CONFIG_HOME=$d/config XDG_DATA_HOME=$d/data \
  ruby "$1/.config/tinted-theming/tinty/hooks/apply-extras.rb" base16-t >/dev/null 2>&1
[ -L "$d/config/workmux/config.yaml" ] || { echo "workmux config.yaml symlink was replaced"; exit 1; }
grep -q 'accent: "#0000ff"' "$d/repo/config.yaml" || { echo "workmux colours not written through"; exit 1; }
