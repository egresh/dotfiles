#!/usr/bin/env lua

package.path = os.getenv("HOME") .. "/dev/dotfiles/sketchybar/sketchybar/plugins/?.lua;" ..
               os.getenv("HOME") .. "/dev/dotfiles/yabai/yabai/scripts/?.lua;" ..
               package.path

local yabai = require 'yabai'
local bar   = require 'sketchybar'

local item_name       = os.getenv("NAME")
local sender          = os.getenv("SENDER")
local current_program = os.getenv("INFO")

local window = yabai:getCurrentWindow()
local has_fullscreen_zoom = window["has-fullscreen-zoom"]
local has_parent_zoom = window["has-parent-zoom"]

local scheme = yabai:getCurrentSpace()["type"]

local modal = ''

if scheme == "bsp" then
    if has_fullscreen_zoom == true then
        modal = "BZ"
    elseif has_parent_zoom == true then
        modal = "Bz"
    else
        modal = "B"
    end
elseif scheme == "stack" then
    modal = "S"
else
    modal = "F"
end

local to_execute = bar.bin .. " --set " .. item_name .. " icon=" .. modal
os.execute(to_execute)
