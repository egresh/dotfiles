#!/usr/bin/env sh

echo "NAME: $NAME"
echo "SENDER: $SENDER"
echo "INFO: $INFO"
val="sketchybar --set $NAME label=\"$INFO\""

echo $val

sketchybar --set $NAME label=$INFO
