#!/bin/sh
# Run after ./bootstrap.sh on a new machine: did fish and tmux end up fully set up?
# (test.sh is hermetic; this checks the real HOME, including what bootstrap fetched.)
cd "$(dirname "$0")" || exit 1
rc=0
bad() { echo "FAIL $*"; rc=1; }

fish -c 'functions -q fisher' || bad "fisher is not installed"

for p in $(grep -v '^#' packages/fish/dot-config/fish/fish_plugins); do
  fish -c 'contains -- $argv[1] $_fisher_plugins' "$p" || bad "plugin not installed: $p"
done

# A real completion file in one of fish's completion dirs (config dir or Homebrew's vendor dir).
# Not `complete -C`: that is never empty (file names, man-page-generated completions).
for t in sesh tinty omniwmctl workmux mise; do
  command -v "$t" >/dev/null 2>&1 || { echo "skip $t (not installed)"; continue; }
  fish -c 'for d in $fish_complete_path
             string match -q "*generated_completions" $d; and continue
             test -s $d/$argv[1].fish; and exit 0
           end; exit 1' "$t" || bad "no fish completion file for $t"
done

[ -x "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tpm/tpm" ] || bad "TPM is not installed"

[ $rc -eq 0 ] && echo ok
exit $rc
