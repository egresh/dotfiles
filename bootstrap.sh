#!/bin/sh
# Link every package, then do what stow can't: fish plugins and generated completions.
# Safe to re-run; re-run after upgrading sesh/tinty/omniwmctl to refresh completions.
set -eu
cd "$(dirname "$0")"

for dir in packages/*/; do stow "$(basename "$dir")"; done

# fisher bootstraps itself, then installs everything listed in fish_plugins
fish -c 'type -q fisher; or curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; fisher update'

# These tools don't ship fish completions (mise and workmux do, via Homebrew), so generate them.
comp=${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions
mkdir -p "$comp"
gen() {
  name=$1; shift
  if command -v "$name" >/dev/null 2>&1 && "$@" >"$comp/$name.fish.tmp"; then
    mv "$comp/$name.fish.tmp" "$comp/$name.fish"
  else
    rm -f "$comp/$name.fish.tmp"; echo "skipped $name completions (not installed or generation failed)"
  fi
}
gen sesh sesh completion fish
gen tinty tinty generate-completion fish
gen omniwmctl omniwmctl completion fish
