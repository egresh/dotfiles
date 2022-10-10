#!/usr/bin/env lua

package.path = os.getenv("HOME") .. "/dev/dotfiles/sketchybar/sketchybar/plugins/?.lua;" ..
               os.getenv("HOME") .. "/dev/dotfiles/yabai/yabai/scripts/?.lua;" ..
               package.path

local yabai = require 'yabai'
local bar   = require 'sketchybar'

local item_name       = os.getenv("NAME")
local sender          = os.getenv("SENDER")
local current_program = os.getenv("INFO") or yabai:getCurrentWindow()["app"]

local external_index = nil

for _, display in pairs(yabai:getDisplays()) do
    if display["uuid"] ~= "37D8832A-2D66-02CA-B9F7-8F30A301B230" then
        external_index = display["index"]
    end
end

local apps = {
    "iStat Menus Status,com.bjango.istatmenus.cpu",
    "iStat Menus Status,com.bjango.istatmenus.memory",
    "iStat Menus Status,com.bjango.istatmenus.network",
    "iStat Menus Status,com.bjango.istatmenus.diskusage",
    "istats_metric"
}

local command = bar.bin

if external_index then
    for _, app in ipairs(apps) do
        command = command .. ' --set "' .. app .. '" associated_display=' .. external_index
    end
else
    for _, app in ipairs(apps) do
        command = command .. ' --set "' .. app .. '" associated_display=0'
    end
end

os.execute(command)
