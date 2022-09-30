#!/bin/bash

type=`yabai -m query --spaces --space | jq '.type' | sed -e s/\"//g`

case $type in
  "bsp")
    scheme="B";;
  "float")
    scheme="F";;
  "stack")
    scheme="S";;
  *)
    scheme="?";;
esac

sketchybar --set modal_indicator \
                 icon=$scheme
