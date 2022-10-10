#!/usr/bin/env lua

package.path = os.getenv("HOME") .. "/dev/dotfiles/sketchybar/sketchybar/plugins/?.lua;" ..
               os.getenv("HOME") .. "/dev/dotfiles/yabai/yabai/scripts/?.lua;" ..
               package.path

local yabai = require 'yabai'
local bar   = require 'sketchybar'

local item_name       = os.getenv("NAME")
local sender          = os.getenv("SENDER")
local current_program = os.getenv("INFO") or yabai:getCurrentWindow()["app"]

local yabai_label = yabai:getCurrentSpaceLabel()

local to_execute = bar.bin .. " --set " .. item_name ..
                              " label=" .. current_program
os.execute(to_execute)
