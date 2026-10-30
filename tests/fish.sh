#!/bin/sh
# fish: every stowed .fish file must parse.
rc=0
for f in $(find "$1/.config/fish" -name '*.fish'); do
  fish --no-config -n "$f" || { echo "syntax error: $f"; rc=1; }
done
exit $rc
