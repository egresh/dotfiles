#!/usr/bin/env bash
# Tests for bin/nvim-refs: which nvim a picked ref goes to, and what happens when there is none.
# Everything is stubbed (fzf, nvim, sl) and runs on a throwaway tmux server with a pty client,
# so no real nvim, socket or tmux session is touched.
# The sandbox is under /tmp on purpose: unix socket paths are limited to ~104 bytes.
set -u
script=$(cd "$(dirname "$0")/.." && pwd)/packages/bin/bin/nvim-refs
sb=$(mktemp -d /tmp/nvr.XXXXXX); sb=$(cd "$sb" && pwd -P)
TM="tmux -L nvrefs-$$ -f /dev/null"
trap '$TM kill-server 2>/dev/null; rm -rf "$sb"' EXIT
export HOME=$sb/home; unset TMUX XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
mkdir -p "$HOME/bin" "$sb/stub" "$sb/socks" "$sb/log"
rc=0

# --- stubs -----------------------------------------------------------------
printf '#!/bin/sh\nhead -1\n' > "$sb/stub/fzf"
cat > "$sb/stub/nvim" <<'E'
#!/bin/sh
# fake nvim: nvim --server SOCK --remote-expr EXPR
[ -S "$2" ] || { echo "E247: no such server" >&2; exit 1; }
case "$4" in
  getcwd*) cat "$2.cwd" ;;
  getpid*) cat "$2.pid" ;;
  *) echo "$2" >> "$LOG/rpc" ;;
esac
E
# (new windows inherit the tmux server's env, not run-shell's, so this stub gets its path baked in)
printf '#!/bin/sh\necho "$PWD $*" >> "%s/log/sl"\n' "$sb" > "$HOME/bin/sl"
chmod +x "$sb/stub/"* "$HOME/bin/sl"

# --- two checkouts of one repo: main and a linked worktree ------------------
git init -q -b main "$sb/main"
git -C "$sb/main" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
git -C "$sb/main" worktree add -q "$sb/feature" -b feature
for d in main feature; do echo hi > "$sb/$d/a.txt"; done
MAIN=$(cd "$sb/main" && pwd -P); FEAT=$(cd "$sb/feature" && pwd -P)

# --- helpers ----------------------------------------------------------------
mksock() { # <root-or-name> <nvim cwd> [pid]   -> a live-looking socket + its fake answers
  local s="$sb/socks/nvim-lazyvim-${1//[^A-Za-z0-9]/_}.sock"
  python3 -I -c 'import socket,sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])' "$s"
  echo "$2" > "$s.cwd"; echo "${3:-1}" > "$s.pid"; echo "$s"
}
start() { # <pane dir>: server with window 0 in <dir>, window 1 elsewhere, a client attached
  $TM kill-server 2>/dev/null; rm -f "$sb/log/"* "$sb/socks/"*; : > "$sb/cands"
  $TM new-session -d -s w -c "$1" -x 100 -y 30
  $TM new-window -t w:1 -c "$sb"; $TM select-window -t w:0
  ( script -q /dev/null $TM attach -t w >/dev/null 2>&1 < <(sleep 30) & )
  for _ in $(seq 20); do [ -n "$($TM list-clients 2>/dev/null)" ] && break; sleep 0.2; done
}
pick() { # <ref>
  echo "$1" > "$sb/cands"
  $TM run-shell "PATH=$sb/stub:\$PATH LOG=$sb/log NVIM_REFS_SOCKDIR=$sb/socks NVIM_REFS_CANDS=$sb/cands bash $script"
  sleep 0.7
}
check() { # <name> <got> <want>
  if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1"; echo "       got:  ${2:-<nothing>}"; echo "       want: $3"; rc=1; fi
}
rpc() { cat "$sb/log/rpc" 2>/dev/null; }
sl()  { cat "$sb/log/sl" 2>/dev/null; }

# --- cases ------------------------------------------------------------------
start "$MAIN"; s=$(mksock "$MAIN" "$MAIN"); pick a.txt:1
check "uses the socket for the pane's own repo" "$(rpc)" "$s"
check "  and starts no new nvim" "$(sl)" ""

start "$FEAT"; mksock "$MAIN" "$MAIN" >/dev/null; pick a.txt:1
check "worktree: another repo's lone nvim is NOT used" "$(rpc)" ""
check "worktree: a new nvim starts in the worktree" "$(sl)" "$FEAT +1 $FEAT/a.txt"

start "$MAIN"; s=$(mksock home "$sb"); pick a.txt:1
check "lone nvim started in a parent dir is used" "$(rpc)" "$s"

start "$MAIN"; pick a.txt:42
check "no nvim at all: new window, line number kept" "$(sl)" "$MAIN +42 $MAIN/a.txt"

start "$MAIN"; pick a.txt
check "bare filename ref opens at line 1" "$(sl)" "$MAIN +1 $MAIN/a.txt"

start "$MAIN"; mksock x "$sb/elsewhere" >/dev/null; mksock y "$sb/elsewhere" >/dev/null; pick a.txt:1
check "two unrelated nvims, none for this repo: new window" "$(sl)" "$MAIN +1 $MAIN/a.txt"

start "$MAIN"; s=$(mksock "$MAIN" "$MAIN" "$($TM display -p -t w:1 '#{pane_pid}')"); pick a.txt:1
check "focus moves to the window holding the nvim" "$($TM display -p -t w '#{window_index}')" "1"

[ $rc -eq 0 ] && echo "all ok"
exit $rc
