#!/bin/sh
# Stow every package into a throwaway HOME and check the links.
# Uses the real .stowrc (it expands $HOME), so it tests that too.
# Package checks: tests/<pkg>.sh, run with $1 = the sandbox HOME.
set -u
cd "$(dirname "$0")" || exit 1
root=$PWD
sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT
rc=0
bad() { echo "FAIL $*"; rc=1; }

# tracked files that .gitignore says should not exist
for f in $(git ls-files -ci --exclude-standard); do bad "tracked but ignored: $f"; done

for dir in packages/*/; do
  pkg=$(basename "$dir")
  if ! HOME=$sandbox stow "$pkg" 2>"$sandbox/err"; then
    bad "$pkg: stow failed: $(cat "$sandbox/err")"
    continue
  fi
  # every file in the package must be a link resolving back to it
  for f in $(cd "$dir" && find . -type f | sed 's|^\./||'); do
    dest=$(echo "$f" | sed -E 's|(^\|/)dot-|\1.|g')
    [ -L "$sandbox/$dest" ] || { bad "$pkg: $dest is not a symlink"; continue; }
    [ "$sandbox/$dest" -ef "$dir$f" ] || bad "$pkg: $dest does not point at $dir$f"
  done
  [ -x "tests/$pkg.sh" ] && { "tests/$pkg.sh" "$sandbox" || bad "$pkg: tests/$pkg.sh"; }
done

# nothing broken, nothing that isn't a link
for l in $(find "$sandbox" -type l ! -exec test -e {} \; -print); do bad "broken link: $l"; done
for f in $(find "$sandbox" -type f ! -name err); do bad "real file in HOME (link expected): $f"; done

[ $rc -eq 0 ] && echo "ok"
exit $rc
